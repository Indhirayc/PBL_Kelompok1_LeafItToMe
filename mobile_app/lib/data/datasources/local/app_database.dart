import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/database/database_schema.dart';
import '../../models/guide_content_model.dart';
import '../../models/scan_record_model.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('leafittome.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(
      path,
      version: kLeafItToMeDatabaseVersion,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON;'),
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    for (final statement in kLeafItToMeSchema) {
      await db.execute(statement);
    }
    await _seedReferenceData(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // v1 -> v2: tambah kolom synced_at pada scan_history (tanpa hapus data).
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE scan_history ADD COLUMN synced_at TEXT');
    }
    // v2 -> v3: scan_history (denormalized) -> 7 tabel sesuai proposal.
    if (oldVersion < 3) {
      await _migrateV2ToV3(db);
    }
    // v3 -> v4: tambah video_url pada panduan_menanam + seed panduan.
    if (oldVersion < 4) {
      await _migrateV3ToV4(db);
    }
  }

  Future<void> _seedReferenceData(Database db) async {
    for (final disease in kLeafItToMeSeedDiseases) {
      await db.insert(
        'penyakit',
        disease,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await _seedGuides(db);
  }

  Future<void> _seedGuides(Database db) async {
    for (final guide in kLeafItToMeSeedGuides) {
      await db.insert(
        'panduan_menanam',
        guide,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );

      final guideId = guide['id_panduan'] as String;
      final videoUrl = guide['video_url'] as String?;
      if (videoUrl != null) {
        await db.update(
          'panduan_menanam',
          {'video_url': videoUrl},
          where: 'id_panduan = ? AND (video_url IS NULL OR video_url = ?)',
          whereArgs: [guideId, ''],
        );
      }
    }
  }

  Future<void> _migrateV3ToV4(Database db) async {
    if (!await _columnExists(db, 'panduan_menanam', 'video_url')) {
      await db.execute('ALTER TABLE panduan_menanam ADD COLUMN video_url TEXT');
    }
    await _seedGuides(db);
  }

  Future<bool> _columnExists(Database db, String table, String column) async {
    final rows = await db.rawQuery('PRAGMA table_info($table)');
    return rows.any((row) => row['name'] == column);
  }

  Future<void> _migrateV2ToV3(Database db) async {
    final hasScanHistory = await _tableExists(db, 'scan_history');
    final legacyRows = hasScanHistory
        ? await db.query('scan_history')
        : const <Map<String, Object?>>[];

    if (!await _tableExists(db, 'pengguna')) {
      for (final statement in kLeafItToMeSchema) {
        await db.execute(statement);
      }
      await _seedReferenceData(db);
    }

    for (final row in legacyRows) {
      final userId = row['user_id'] as String? ?? 'unknown';
      final scannedAt =
          row['scanned_at'] as String? ?? DateTime.now().toIso8601String();
      final diseaseName =
          row['disease_name'] as String? ?? 'Penyakit Tidak Diketahui';
      final isSynced = (row['is_synced'] as int? ?? 0) == 1;

      await _ensureUserById(db, userId, userId, scannedAt);

      final plantId = 'TMT-DEFAULT-$userId';
      await db.insert('tanaman', {
        'id_tanaman': plantId,
        'id_pengguna': userId,
        'nama_tanaman': 'Tanaman Saya',
        'lokasi': null,
        'tanggal_tanam': null,
        'status_sinkronisasi': 'pending',
        'created_at': scannedAt,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);

      final diseaseId = await _resolveDiseaseId(db, diseaseName);
      await db.insert('riwayat_pemindaian', {
        'id_riwayat': row['id'],
        'id_tanaman': plantId,
        'id_penyakit': diseaseId,
        'foto_daun': row['local_image_path'],
        'cloud_image_url': row['cloud_image_url'],
        'confidence_score': row['confidence'],
        'tanggal_pemeriksaan': scannedAt,
        'catatan': row['notes'],
        'status_sinkronisasi': isSynced ? 'synced' : 'pending',
        'synced_at': row['synced_at'],
        'created_at': scannedAt,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    if (hasScanHistory) {
      await db.execute('DROP TABLE scan_history');
    }
  }

  Future<bool> _tableExists(Database db, String table) async {
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      [table],
    );
    return result.isNotEmpty;
  }

  Future<int> insertScan(ScanRecordModel scan) async {
    final db = await database;
    await _ensureUser(db, scan);
    final plantId = await _ensurePlant(db, scan);
    final diseaseId = await _resolveDiseaseId(db, scan.diseaseName);
    final now = DateTime.now().toIso8601String();

    return await db.insert('riwayat_pemindaian', {
      'id_riwayat': scan.id,
      'id_tanaman': plantId,
      'id_penyakit': diseaseId,
      'foto_daun': scan.localImagePath,
      'cloud_image_url': scan.cloudImageUrl,
      'confidence_score': scan.confidence,
      'tanggal_pemeriksaan': scan.scannedAt.toIso8601String(),
      'catatan': scan.notes,
      'status_sinkronisasi': scan.isSynced ? 'synced' : 'pending',
      'synced_at': scan.isSynced ? now : null,
      'created_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ScanRecordModel>> getScansByUser(String userId) async {
    final db = await database;
    final result = await db.rawQuery(
      '$_scanSelect WHERE t.id_pengguna = ? '
      'ORDER BY r.tanggal_pemeriksaan DESC',
      [userId],
    );
    return result.map(_mapRowToScan).toList();
  }

  Future<List<ScanRecordModel>> getUnsyncedScans(String userId) async {
    final db = await database;
    final result = await db.rawQuery(
      '$_scanSelect WHERE t.id_pengguna = ? '
      "AND r.status_sinkronisasi = 'pending' "
      'ORDER BY r.tanggal_pemeriksaan ASC',
      [userId],
    );
    return result.map(_mapRowToScan).toList();
  }

  Future<List<GuideContentModel>> getGuideContents() async {
    final db = await database;
    final result = await db.query('panduan_menanam', orderBy: 'id_panduan ASC');
    return result.map(GuideContentModel.fromMap).toList();
  }

  Future<int> markAsSynced(String id, String? cloudImageUrl) async {
    final db = await database;
    return await db.update(
      'riwayat_pemindaian',
      {
        'status_sinkronisasi': 'synced',
        'cloud_image_url': cloudImageUrl,
        'synced_at': DateTime.now().toIso8601String(),
      },
      where: 'id_riwayat = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteScan(String id) async {
    final db = await database;
    return await db.delete(
      'riwayat_pemindaian',
      where: 'id_riwayat = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  Future<void> _ensureUser(Database db, ScanRecordModel scan) async {
    await _ensureUserById(
      db,
      scan.userId,
      scan.userId,
      DateTime.now().toIso8601String(),
    );
  }

  Future<void> _ensureUserById(
    Database db,
    String id,
    String fullName,
    String createdAt,
  ) async {
    await db.insert('pengguna', {
      'id_pengguna': id,
      'nama_lengkap': fullName,
      'email': '$id@local.invalid',
      'foto_profil': null,
      'created_at': createdAt,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<String> _ensurePlant(Database db, ScanRecordModel scan) async {
    final plantId = scan.plantId ?? 'TMT-DEFAULT-${scan.userId}';
    await db.insert('tanaman', {
      'id_tanaman': plantId,
      'id_pengguna': scan.userId,
      'nama_tanaman': scan.plantName ?? 'Tanaman Saya',
      'lokasi': scan.plantLocation,
      'tanggal_tanam': null,
      'status_sinkronisasi': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
    return plantId;
  }

  Future<String> _resolveDiseaseId(Database db, String diseaseName) async {
    final name = diseaseName.trim();
    final slug = _slugify(name);
    if (name.isNotEmpty) {
      final candidates = <String>{name, slug, _diseaseAliases[slug] ?? name};
      for (final candidate in candidates) {
        final result = await db.query(
          'penyakit',
          columns: ['id_penyakit'],
          where:
              'LOWER(nama_penyakit) = LOWER(?) OR LOWER(label_code) = LOWER(?)',
          whereArgs: [candidate, candidate],
          limit: 1,
        );
        if (result.isNotEmpty) {
          return result.first['id_penyakit'] as String;
        }
      }
    }

    final diseaseId = 'CUSTOM-${slug.toUpperCase()}';
    await db.insert('penyakit', {
      'id_penyakit': diseaseId,
      'label_code': slug,
      'nama_penyakit': name.isEmpty ? 'Penyakit Tidak Diketahui' : name,
      'nama_latin': null,
      'deskripsi': null,
      'kategori': null,
      'tingkat_risiko': 'sedang',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
    return diseaseId;
  }

  String _slugify(String value) {
    final slug = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return slug.isEmpty ? 'penyakit_tidak_diketahui' : slug;
  }

  ScanRecordModel _mapRowToScan(Map<String, Object?> row) {
    return ScanRecordModel(
      id: row['id_riwayat'] as String,
      userId: row['id_pengguna'] as String,
      diseaseName: row['nama_penyakit'] as String,
      confidence: (row['confidence_score'] as num).toDouble(),
      localImagePath: (row['foto_daun'] as String?) ?? '',
      cloudImageUrl: row['cloud_image_url'] as String?,
      notes: row['catatan'] as String?,
      scannedAt: DateTime.parse(row['tanggal_pemeriksaan'] as String),
      isSynced: row['status_sinkronisasi'] == 'synced',
      plantId: row['id_tanaman'] as String?,
    );
  }

  static const Map<String, String> _diseaseAliases = <String, String>{
    'bacterial_spot': 'Bacterial_Spot',
    'late_blight': 'Late_Blight',
    'leaf_mold': 'Leaf_Mold',
    'tylcv': 'TYLCV',
    'tomato_yellow_leaf_curl_virus': 'TYLCV',
    'tomato_yellow_leaf_curl_virus_tylcv': 'TYLCV',
    'healthy': 'Healthy',
  };

  static const String _scanSelect = '''
SELECT r.id_riwayat, t.id_pengguna, t.id_tanaman, p.nama_penyakit,
       r.foto_daun, r.cloud_image_url, r.confidence_score,
       r.tanggal_pemeriksaan, r.catatan, r.status_sinkronisasi
FROM riwayat_pemindaian r
JOIN tanaman t ON t.id_tanaman = r.id_tanaman
JOIN penyakit p ON p.id_penyakit = r.id_penyakit
''';
}
