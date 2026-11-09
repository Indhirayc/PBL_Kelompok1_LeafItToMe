import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/data/datasources/local/app_database.dart';
import 'package:mobile_app/data/datasources/local/sync_queue_dao.dart';
import 'package:mobile_app/data/models/scan_record_model.dart';
import 'package:mobile_app/data/repositories/plant_repository.dart';
import 'package:mobile_app/features/plants/models/plant.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tempDirectory;
  late AppDatabase appDatabase;
  late PlantRepository plantRepository;

  setUpAll(() {
    sqfliteFfiInit();
  });

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('leafittome_db_');
    appDatabase = AppDatabase.forTesting(
      databaseFactory: databaseFactoryFfi,
      databasePath: path.join(tempDirectory.path, 'test.db'),
    );
    plantRepository = PlantRepository(database: appDatabase);
  });

  tearDown(() async {
    await appDatabase.close();
    await tempDirectory.delete(recursive: true);
  });

  test('creates all v2 tables and enables foreign keys', () async {
    final db = await appDatabase.database;
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    );
    final names = tables.map((row) => row['name']).toSet();

    expect(
      names,
      containsAll({
        'plants',
        'scans',
        'diseases',
        'guides',
        'tools',
        'products',
        'sync_queue',
        'app_meta',
      }),
    );
    expect(
      (await db.rawQuery('PRAGMA foreign_keys')).single['foreign_keys'],
      1,
    );
  });

  test(
    'migrates v1 scans and queues unsynced rows without data loss',
    () async {
      final databasePath = path.join(tempDirectory.path, 'migration.db');
      final oldDatabase = await databaseFactoryFfi.openDatabase(
        databasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
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
            await db.insert('scan_history', {
              'id': 'old-scan',
              'user_id': 'user-1',
              'disease_name': 'Leaf spot',
              'confidence': 0.9,
              'local_image_path': '/tmp/leaf.jpg',
              'notes': 'legacy note',
              'scanned_at': '2026-10-23T12:00:00Z',
              'is_synced': 0,
            });
            await db.insert('scan_history', {
              'id': 'synced-scan',
              'user_id': 'user-1',
              'disease_name': 'Healthy',
              'confidence': 0.99,
              'local_image_path': '/tmp/healthy.jpg',
              'scanned_at': '2026-10-22T12:00:00Z',
              'is_synced': 1,
            });
          },
        ),
      );
      await oldDatabase.close();
      final migrationDb = AppDatabase.forTesting(
        databaseFactory: databaseFactoryFfi,
        databasePath: databasePath,
      );
      addTearDown(migrationDb.close);

      final db = await migrationDb.database;
      final scans = await db.query('scans');
      final queues = await db.query('sync_queue');

      expect(scans, hasLength(2));
      final pendingScan = scans.singleWhere((row) => row['id'] == 'old-scan');
      final syncedScan = scans.singleWhere((row) => row['id'] == 'synced-scan');
      expect(pendingScan['disease_label'], 'Leaf spot');
      expect(pendingScan['plant_id'], isNull);
      expect(pendingScan['sync_status'], 'pending');
      expect(pendingScan['scanned_at'], '2026-10-23T12:00:00.000Z');
      expect(syncedScan['disease_label'], 'Healthy');
      expect(syncedScan['sync_status'], 'synced');
      expect(queues, hasLength(1));
      expect(queues.single['entity_id'], 'old-scan');
      expect(
        await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE name = 'scan_history'",
        ),
        isEmpty,
      );
    },
  );

  test('plant CRUD uses UTC dates and soft delete', () async {
    const plant = Plant(
      id: 'plant-1',
      name: 'Tomato',
      location: 'Balcony',
      plantedDate: '12 Okt 2026',
      lastInspectionDate: 'Belum ada pemeriksaan',
      status: 'Sehat',
      note: 'Pot besar',
    );

    await plantRepository.create(plant);
    final created = await plantRepository.getById('plant-1');
    final row = (await (await appDatabase.database).query('plants')).single;
    expect(created?.plantedDate, '12 Okt 2026');
    expect(created?.lastInspectionDate, 'Belum ada pemeriksaan');
    expect(row['planted_at'], '2026-10-12T00:00:00.000Z');

    expect(
      await plantRepository.update(plant.copyWith(status: 'Perlu diperiksa')),
      1,
    );
    expect(
      (await plantRepository.getById('plant-1'))?.status,
      'Perlu diperiksa',
    );
    expect(await plantRepository.softDelete('plant-1'), 1);
    expect(await plantRepository.getById('plant-1'), isNull);
    expect(await plantRepository.getAll(), isEmpty);
    expect(
      (await (await appDatabase.database).query('plants')).single['deleted_at'],
      isA<String>(),
    );
  });

  test(
    'scan transaction updates plant and queues sync; sync clears queue',
    () async {
      const plant = Plant(
        id: 'plant-2',
        name: 'Tomato',
        location: 'Garden',
        plantedDate: '2026-10-01',
        lastInspectionDate: '2026-10-20',
        status: 'Sehat',
      );
      await plantRepository.create(plant);
      final scan = ScanRecordModel(
        id: 'scan-2',
        userId: 'user-2',
        plantId: plant.id,
        diseaseName: 'Early blight',
        confidence: 0.95,
        localImagePath: '/tmp/scan.jpg',
        scannedAt: DateTime.utc(2026, 10, 23),
      );

      await appDatabase.saveScanResult(scan);
      final db = await appDatabase.database;
      expect(await db.query('scans'), hasLength(1));
      expect((await plantRepository.getById(plant.id))?.status, 'Early blight');
      expect(await appDatabase.syncQueueDao.getPending(), hasLength(1));
      expect(await appDatabase.getUnsyncedScans('user-2'), hasLength(1));

      await appDatabase.markAsSynced(scan.id, 'https://example.com/scan.jpg');
      expect(await appDatabase.getUnsyncedScans('user-2'), isEmpty);
      expect(await appDatabase.syncQueueDao.getPending(), isEmpty);
    },
  );

  test('sync queue upsert does not duplicate an operation', () async {
    final SyncQueueDao queue = appDatabase.syncQueueDao;
    await queue.enqueue(
      entityType: 'guide',
      entityId: 'guide-1',
      operation: 'upsert',
      payload: '{"version":1}',
    );
    await queue.enqueue(
      entityType: 'guide',
      entityId: 'guide-1',
      operation: 'upsert',
      payload: '{"version":2}',
    );

    final pending = await queue.getPending();
    expect(pending, hasLength(1));
    expect(pending.single['payload'], '{"version":2}');
  });
}
