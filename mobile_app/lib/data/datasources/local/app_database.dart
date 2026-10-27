import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_schema.dart';
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
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // v1 -> v2: tambah kolom synced_at pada scan_history (tanpa hapus data).
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE scan_history ADD COLUMN synced_at TEXT');
    }
  }

  Future<int> insertScan(ScanRecordModel scan) async {
    final db = await instance.database;
    return await db.insert(
      'scan_history',
      scan.toSqliteMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ScanRecordModel>> getScansByUser(String userId) async {
    final db = await instance.database;
    final result = await db.query(
      'scan_history',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'scanned_at DESC',
    );
    return result.map((json) => ScanRecordModel.fromSqliteMap(json)).toList();
  }

  Future<List<ScanRecordModel>> getUnsyncedScans(String userId) async {
    final db = await instance.database;
    final result = await db.query(
      'scan_history',
      where: 'user_id = ? AND is_synced = 0',
      whereArgs: [userId],
    );
    return result.map((json) => ScanRecordModel.fromSqliteMap(json)).toList();
  }

  Future<int> markAsSynced(String id, String cloudImageUrl) async {
    final db = await instance.database;
    return await db.update(
      'scan_history',
      {
        'is_synced': 1,
        'cloud_image_url': cloudImageUrl,
        'synced_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
