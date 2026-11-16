import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/database/database_schema.dart';
import '../../../core/utils/disease_label_mapper.dart';
import '../../models/guide_content_model.dart';
import '../../models/scan_record_model.dart';
import 'sync_queue_dao.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();

  AppDatabase._init() : _databaseFactory = null, _databasePath = null;

  AppDatabase.forTesting({
    required this._databaseFactory,
    required this._databasePath,
  });

  final DatabaseFactory? _databaseFactory;
  final String? _databasePath;
  Database? _database;

  late final SyncQueueDao syncQueueDao = SyncQueueDao(() => database);

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('leafittome.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final path = _databasePath ?? join(await getDatabasesPath(), filePath);
    final options = OpenDatabaseOptions(
      version: _kSchemaVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );

    if (_databaseFactory != null) {
      return _databaseFactory.openDatabase(path, options: options);
    }

    return openDatabase(
      path,
      version: _kSchemaVersion,
      onConfigure: options.onConfigure,
      onCreate: options.onCreate,
      onUpgrade: options.onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await _createSchema(db);
    await _seedGuides(db);
  }

  Future<void> _createSchema(DatabaseExecutor db) async {
    for (final sql in kLeafItToMeSchema) {
      await db.execute(sql);
    }
    await db.execute(
      'INSERT OR REPLACE INTO app_meta (key, value, updated_at) '
      'VALUES (?, ?, ?)',
      ['schema_version', '$_kSchemaVersion', _utcNow()],
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE scan_history RENAME TO scan_history_legacy',
      );
      await _createSchema(db);
      final legacyRows = await db.query('scan_history_legacy');
      for (final row in legacyRows) {
        final scannedAt = DateTime.parse(row['scanned_at'] as String)
            .toUtc()
            .toIso8601String();
        final isSynced = row['is_synced'] == 1;
        final scan = <String, Object?>{
          'id': row['id'],
          'user_id': row['user_id'],
          'plant_id': null,
          'disease_label': row['disease_name'],
          'confidence': row['confidence'],
          'local_image_path': row['local_image_path'],
          'cloud_image_url': row['cloud_image_url'],
          'notes': row['notes'],
          'scanned_at': scannedAt,
          'sync_status': isSynced ? 'synced' : 'pending',
        };
        await db.insert('scans', scan);
        if (!isSynced) {
          await db.insert('sync_queue', {
            'id': 'scan:${row['id']}:upsert',
            'entity_type': 'scan',
            'entity_id': row['id'],
            'operation': 'upsert',
            'payload': jsonEncode(scan),
            'created_at': _utcNow(),
          });
        }
      }
      await db.execute('DROP TABLE scan_history_legacy');
      await _seedGuides(db);
      return;
    }

    // Database versi 3 lama memakai schema Indonesia (pengguna, tanaman, ...).
    // Schema itu tidak kompatibel dengan v2, jadi tabel lamanya dibuang.
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    );
    final existing = tables.map((row) => row['name'] as String).toSet();
    if (existing.contains('pengguna')) {
      const legacyTables = <String>[
        'riwayat_pemindaian',
        'penanganan',
        'panduan_menanam',
        'rekomendasi_produk',
        'penyakit',
        'tanaman',
        'pengguna',
      ];
      for (final table in legacyTables) {
        await db.execute('DROP TABLE IF EXISTS $table');
      }
    }

    if (!existing.contains('plants')) {
      await _createSchema(db);
    } else {
      await db.execute(
        'INSERT OR REPLACE INTO app_meta (key, value, updated_at) '
        'VALUES (?, ?, ?)',
        ['schema_version', '$_kSchemaVersion', _utcNow()],
      );
    }

    // v5 -> v6: add ownership to plants from existing installations.
    if (!await _columnExists(db, 'plants', 'user_id')) {
      await db.execute(
        "ALTER TABLE plants ADD COLUMN user_id TEXT NOT NULL DEFAULT 'user-local'",
      );
    }
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_plants_user ON plants (user_id)',
    );

    // v4 -> v5: tambah video_url pada guides lalu seed video panduan.
    if (!await _columnExists(db, 'guides', 'video_url')) {
      await db.execute('ALTER TABLE guides ADD COLUMN video_url TEXT');
    }
    await _seedGuides(db);
  }

  Future<void> _seedGuides(DatabaseExecutor db) async {
    for (final guide in kLeafItToMeSeedGuides) {
      final guideId = guide['id_panduan'] as String;
      final videoUrl = guide['video_url'] as String?;

      await db.insert(
        'guides',
        {
          'id': guideId,
          'title': guide['judul'],
          'description': guide['deskripsi'],
          'content': guide['langkah_langkah'] ?? '',
          'category': guide['kategori'],
          'video_url': videoUrl,
          'updated_at': guide['created_at'] ?? _utcNow(),
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );

      if (videoUrl != null) {
        await db.update(
          'guides',
          {'video_url': videoUrl},
          where: 'id = ? AND video_url IS NULL',
          whereArgs: [guideId],
        );
      }
    }
  }

  Future<bool> _columnExists(
    DatabaseExecutor db,
    String table,
    String column,
  ) async {
    final rows = await db.rawQuery('PRAGMA table_info($table)');
    return rows.any((row) => row['name'] == column);
  }

  Future<int> insertScan(
    ScanRecordModel scan, {
    DatabaseExecutor? executor,
  }) async {
    final db = executor ?? await database;
    return db.insert(
      'scans',
      scan.toSqliteMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveScanResult(ScanRecordModel scan) async {
    final db = await database;
    await db.transaction((transaction) async {
      if (scan.plantId != null) {
        final ownedPlants = await transaction.query(
          'plants',
          columns: ['id'],
          where: 'id = ? AND user_id = ? AND deleted_at IS NULL',
          whereArgs: [scan.plantId, scan.userId],
          limit: 1,
        );
        if (ownedPlants.isEmpty) {
          throw StateError(
            'Tanaman ${scan.plantId} tidak ditemukan di akun pemilik scan.',
          );
        }
      }

      await insertScan(scan, executor: transaction);
      if (scan.plantId != null) {
        await transaction.update(
          'plants',
          {
            'status': DiseaseLabelMapper.isHealthy(scan.diseaseName)
                ? 'Sehat'
                : scan.diseaseName,
            'last_inspection_at': scan.scannedAt.toUtc().toIso8601String(),
            'updated_at': _utcNow(),
          },
          where: 'id = ? AND user_id = ? AND deleted_at IS NULL',
          whereArgs: [scan.plantId, scan.userId],
        );
      }
      await syncQueueDao.enqueue(
        entityType: 'scan',
        entityId: scan.id,
        operation: 'upsert',
        payload: jsonEncode(scan.toSqliteMap()),
        executor: transaction,
      );
    });
  }

  Future<List<ScanRecordModel>> getScansByUser(String userId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT s.*, p.name AS plant_name, p.location AS plant_location
      FROM scans s
      LEFT JOIN plants p ON p.id = s.plant_id AND p.user_id = s.user_id
      WHERE s.user_id = ?
      ORDER BY s.scanned_at DESC
      ''',
      [userId],
    );
    return result.map(ScanRecordModel.fromSqliteMap).toList();
  }

  Future<List<ScanRecordModel>> getScansByPlantId(
    String plantId,
    String userId,
  ) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT s.*, p.name AS plant_name, p.location AS plant_location
      FROM scans s
      LEFT JOIN plants p ON p.id = s.plant_id AND p.user_id = s.user_id
      WHERE s.plant_id = ? AND s.user_id = ?
      ORDER BY s.scanned_at DESC
      ''',
      [plantId, userId],
    );
    return result.map(ScanRecordModel.fromSqliteMap).toList();
  }

  Future<List<ScanRecordModel>> getUnsyncedScans(String userId) async {
    final db = await database;
    final result = await db.query(
      'scans',
      where: 'user_id = ? AND sync_status = ?',
      whereArgs: [userId, 'pending'],
      orderBy: 'scanned_at',
    );
    return result.map(ScanRecordModel.fromSqliteMap).toList();
  }

  Future<List<GuideContentModel>> getGuideContents() async {
    final db = await database;
    final result = await db.query('guides', orderBy: 'id ASC');
    return result.map(GuideContentModel.fromMap).toList();
  }

  Future<int> deleteScan(String id) async {
    final db = await database;
    final deleted = await db.delete('scans', where: 'id = ?', whereArgs: [id]);
    await syncQueueDao.remove(
      entityType: 'scan',
      entityId: id,
      operation: 'upsert',
      executor: db,
    );
    return deleted;
  }

  Future<int> markAsSynced(String id, String? cloudImageUrl) async {
    final db = await database;
    return db.transaction((transaction) async {
      final values = <String, Object?>{
        'sync_status': 'synced',
        'cloud_image_url': ?cloudImageUrl,
      };
      final updatedCount = await transaction.update(
        'scans',
        values,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (updatedCount == 1) {
        await syncQueueDao.remove(
          entityType: 'scan',
          entityId: id,
          operation: 'upsert',
          executor: transaction,
        );
      }
      return updatedCount;
    });
  }

  /// Simpan item master data (diseases/tools) sebagai JSON di tabel app_meta
  /// agar aplikasi tetap bisa menampilkan data saat offline.
  Future<void> saveMasterCache(
    String key,
    List<Map<String, dynamic>> items,
  ) async {
    final db = await database;
    await db.insert(
      'app_meta',
      {
        'key': 'master_cache_$key',
        'value': jsonEncode(items),
        'updated_at': _utcNow(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Ambil item master data dari cache app_meta; null bila belum tersimpan
  Future<List<Map<String, dynamic>>?> getMasterCache(String key) async {
    final db = await database;
    final rows = await db.query(
      'app_meta',
      where: "key = 'master_cache_$key'",
      limit: 1,
    );
    if (rows.isEmpty) return null;

    final decoded = jsonDecode(rows.first['value'] as String);
    if (decoded is! List) return null;

    return decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}

String _utcNow() => DateTime.now().toUtc().toIso8601String();

/// Versi file database SQLite. Dinaikkan ke 5 agar perangkat yang masih
/// menyimpan database lama (v1 `scan_history`, v3/v4 schema Indonesia, atau
/// v4 schema Inggris tanpa `guides.video_url`) otomatis dimigrasikan, bukan
/// melempar error downgrade.
const int _kSchemaVersion = kLeafItToMeDatabaseVersion;
