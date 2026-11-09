import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
      version: 2,
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
      version: 2,
      onConfigure: options.onConfigure,
      onCreate: options.onCreate,
      onUpgrade: options.onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await _createSchema(db);
  }

  Future<void> _createSchema(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE plants (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        location TEXT NOT NULL,
        planted_at TEXT NOT NULL,
        last_inspection_at TEXT,
        status TEXT NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE scans (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        plant_id TEXT,
        disease_label TEXT NOT NULL,
        confidence REAL NOT NULL,
        local_image_path TEXT NOT NULL,
        cloud_image_url TEXT,
        notes TEXT,
        scanned_at TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'pending'
          CHECK (sync_status IN ('pending', 'synced')),
        FOREIGN KEY (plant_id) REFERENCES plants(id) ON DELETE SET NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE diseases (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        symptoms TEXT,
        treatment TEXT,
        image_url TEXT,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE guides (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        content TEXT NOT NULL,
        category TEXT,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE tools (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        image_url TEXT,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        image_url TEXT,
        price REAL,
        product_url TEXT,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE sync_queue (
        id TEXT PRIMARY KEY,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        payload TEXT NOT NULL,
        created_at TEXT NOT NULL,
        attempts INTEGER NOT NULL DEFAULT 0,
        last_error TEXT,
        UNIQUE (entity_type, entity_id, operation)
      )
    ''');
    await db.execute('''
      CREATE TABLE app_meta (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute(
      'INSERT INTO app_meta (key, value, updated_at) VALUES (?, ?, ?)',
      ['schema_version', '2', _utcNow()],
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
    }
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
      await insertScan(scan, executor: transaction);
      if (scan.plantId != null) {
        await transaction.update(
          'plants',
          {
            'status': scan.diseaseName,
            'last_inspection_at': scan.scannedAt.toUtc().toIso8601String(),
            'updated_at': _utcNow(),
          },
          where: 'id = ? AND deleted_at IS NULL',
          whereArgs: [scan.plantId],
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
    final result = await db.query(
      'scans',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'scanned_at DESC',
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

  Future<int> markAsSynced(String id, String cloudImageUrl) async {
    final db = await database;
    return db.transaction((transaction) async {
      final updatedCount = await transaction.update(
        'scans',
        {'sync_status': 'synced', 'cloud_image_url': cloudImageUrl},
        where: 'id = ?',
        whereArgs: [id],
      );
      await syncQueueDao.remove(
        entityType: 'scan',
        entityId: id,
        operation: 'upsert',
        executor: transaction,
      );
      return updatedCount;
    });
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}

String _utcNow() => DateTime.now().toUtc().toIso8601String();
