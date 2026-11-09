import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/scan_record_model.dart';

class AppDatabase {
  // Singleton pattern: memastikan hanya ada 1 instance koneksi database di aplikasi
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  /// Getter untuk mengambil objek Database SQLite.
  /// Jika belum dibuat, otomatis menginisialisasi file database.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('leafittome.db');
    return _database!;
  }

  /// Membuat path file lokal dan membuka database SQLite
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  /// Membuat skema tabel SQLite saat database pertama kali dibuat
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE scans (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        disease_name TEXT NOT NULL,
        confidence REAL NOT NULL,
        local_image_path TEXT NOT NULL,
        cloud_image_url TEXT,
        notes TEXT,
        scanned_at TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  /// Menyimpan hasil scan baru atau memperbarui data lama jika ID sama
  Future<int> insertScan(ScanRecordModel record) async {
    final db = await database;
    return await db.insert(
      'scans',
      record.toSqliteMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Mengambil semua riwayat pemeriksaan milik user tertentu,
  /// diurutkan dari pemeriksaan paling baru (scanned_at DESC)
  Future<List<ScanRecordModel>> getScansByUser(String userId) async {
    final db = await database;
    final result = await db.query(
      'scans',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'scanned_at DESC',
    );

    return result.map((map) => ScanRecordModel.fromSqliteMap(map)).toList();
  }

  /// Mengambil daftar scan yang BELUM disinkronkan ke cloud (is_synced = 0)
  /// Digunakan oleh SyncManager saat perangkat kembali online
  Future<List<ScanRecordModel>> getUnsyncedScans(String userId) async {
    final db = await database;
    final result = await db.query(
      'scans',
      where: 'user_id = ? AND is_synced = 0',
      whereArgs: [userId],
      orderBy: 'scanned_at ASC',
    );

    return result.map((map) => ScanRecordModel.fromSqliteMap(map)).toList();
  }

  /// Memperbarui status is_synced menjadi 1 (true) dan menyimpan cloudImageUrl
  /// setelah SyncManager berhasil mengunggah data ke Firebase / Cloudinary
  Future<int> markAsSynced(String scanId, String cloudImageUrl) async {
    final db = await database;
    return await db.update(
      'scans',
      {'is_synced': 1, 'cloud_image_url': cloudImageUrl},
      where: 'id = ?',
      whereArgs: [scanId],
    );
  }

  /// Menutup koneksi database jika sudah tidak digunakan
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
