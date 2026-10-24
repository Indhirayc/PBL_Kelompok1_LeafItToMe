import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
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

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE scan_history (
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
