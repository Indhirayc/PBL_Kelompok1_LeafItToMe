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

  test('creates all schema tables and enables foreign keys', () async {
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

  test('adds account ownership to existing plants during upgrade', () async {
    final databasePath = path.join(tempDirectory.path, 'v5.db');
    final oldDatabase = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: 5,
        onCreate: (db, version) async {
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
            CREATE TABLE app_meta (
              key TEXT PRIMARY KEY,
              value TEXT NOT NULL,
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
              video_url TEXT,
              updated_at TEXT NOT NULL
            )
          ''');
          await db.insert('plants', {
            'id': 'legacy-plant',
            'name': 'Legacy Tomato',
            'location': 'Garden',
            'planted_at': '2026-10-12T00:00:00.000Z',
            'status': 'Sehat',
            'created_at': '2026-10-12T00:00:00.000Z',
            'updated_at': '2026-10-12T00:00:00.000Z',
          });
        },
      ),
    );
    await oldDatabase.close();

    final migratedDatabase = AppDatabase.forTesting(
      databaseFactory: databaseFactoryFfi,
      databasePath: databasePath,
    );
    addTearDown(migratedDatabase.close);
    final migratedRepository = PlantRepository(database: migratedDatabase);

    await migratedRepository.claimLegacyPlants('first-user');

    expect(await migratedRepository.getAll(userId: 'user-local'), isEmpty);
    expect(
      (await migratedRepository.getAll(userId: 'first-user')).single.name,
      'Legacy Tomato',
    );
  });

  test('migrates v6 database to v7 by adding image_path column to plants', () async {
    final databasePath = path.join(tempDirectory.path, 'v6.db');
    final oldDatabase = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: 6,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE plants (
              id TEXT PRIMARY KEY,
              user_id TEXT NOT NULL DEFAULT 'user-local',
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
            CREATE TABLE app_meta (
              key TEXT PRIMARY KEY,
              value TEXT NOT NULL,
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
              video_url TEXT,
              updated_at TEXT NOT NULL
            )
          ''');
          await db.insert('plants', {
            'id': 'plant-v6',
            'user_id': 'user-1',
            'name': 'Tomat Ceri',
            'location': 'Kebun A',
            'planted_at': '2026-11-01T00:00:00.000Z',
            'status': 'Sehat',
            'created_at': '2026-11-01T00:00:00.000Z',
            'updated_at': '2026-11-01T00:00:00.000Z',
          });
        },
      ),
    );
    await oldDatabase.close();

    final upgradedDatabase = AppDatabase.forTesting(
      databaseFactory: databaseFactoryFfi,
      databasePath: databasePath,
    );
    addTearDown(upgradedDatabase.close);
    final repo = PlantRepository(database: upgradedDatabase);

    // Verify existing plant still exists and imagePath is null
    final existingPlants = await repo.getAll(userId: 'user-1');
    expect(existingPlants.length, 1);
    expect(existingPlants.first.imagePath, isNull);

    // Verify creating new plant with imagePath succeeds
    const newPlant = Plant(
      id: 'plant-with-photo',
      userId: 'user-1',
      name: 'Tomat Baru',
      location: 'Pot 1',
      plantedDate: '20 November 2026',
      lastInspectionDate: 'Belum ada pemeriksaan',
      status: 'Sehat',
      imagePath: '/path/to/avatar.jpg',
    );
    await repo.create(newPlant);

    final updatedList = await repo.getAll(userId: 'user-1');
    expect(updatedList.length, 2);
    final retrieved = updatedList.firstWhere((p) => p.id == 'plant-with-photo');
    expect(retrieved.imagePath, '/path/to/avatar.jpg');
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

  test('next plant ID accounts for soft-deleted plants', () async {
    const deletedPlant = Plant(
      id: 'TMT-001',
      name: 'Deleted Tomato',
      location: 'Balcony',
      plantedDate: '12 Okt 2026',
      lastInspectionDate: 'Belum ada pemeriksaan',
      status: 'Sehat',
    );
    await plantRepository.create(deletedPlant);
    await plantRepository.softDelete(deletedPlant.id);

    expect(await plantRepository.nextPlantId(), 'TMT-002');
  });

  test(
    'plants are scoped to their owner and legacy plants are claimed once',
    () async {
      const legacyPlant = Plant(
        id: 'legacy-plant',
        name: 'Legacy Tomato',
        location: 'Garden',
        plantedDate: '12 Okt 2026',
        lastInspectionDate: 'Belum ada pemeriksaan',
        status: 'Sehat',
      );
      const secondUserPlant = Plant(
        id: 'second-user-plant',
        name: 'Other Tomato',
        location: 'Balcony',
        plantedDate: '12 Okt 2026',
        lastInspectionDate: 'Belum ada pemeriksaan',
        status: 'Sehat',
        userId: 'user-2',
      );

      await plantRepository.create(legacyPlant);
      await plantRepository.create(secondUserPlant);
      await plantRepository.claimLegacyPlants('user-1');
      await plantRepository.claimLegacyPlants('user-2');

      expect(
        (await plantRepository.getAll(userId: 'user-1'))
            .map((plant) => plant.id),
        ['legacy-plant'],
      );
      expect(
        (await plantRepository.getAll(userId: 'user-2'))
            .map((plant) => plant.id),
        ['second-user-plant'],
      );
      expect(
        await plantRepository.getById('legacy-plant', userId: 'user-2'),
        isNull,
      );
      expect(
        await plantRepository.softDelete('legacy-plant', userId: 'user-2'),
        0,
      );
    },
  );

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
        userId: 'user-2',
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
      expect(
        (await plantRepository.getById(plant.id, userId: 'user-2'))?.status,
        'Early blight',
      );
      expect(
        (await plantRepository.getById(
          plant.id,
          userId: 'user-2',
        ))?.lastInspectionDate,
        '23 Okt 2026',
      );
      expect(await appDatabase.syncQueueDao.getPending(), hasLength(1));
      expect(await appDatabase.getUnsyncedScans('user-2'), hasLength(1));

      expect(await appDatabase.markAsSynced('missing-scan', null), 0);
      expect(await appDatabase.syncQueueDao.getPending(), hasLength(1));

      await appDatabase.markAsSynced(scan.id, 'https://example.com/scan.jpg');
      expect(await appDatabase.getUnsyncedScans('user-2'), isEmpty);
      expect(await appDatabase.syncQueueDao.getPending(), isEmpty);
    },
  );

  test('filters plant scan history by plant and user', () async {
    const firstPlant = Plant(
      id: 'plant-history-1',
      name: 'Tomato One',
      location: 'Garden',
      plantedDate: '2026-10-01',
      lastInspectionDate: 'Belum ada pemeriksaan',
      status: 'Sehat',
      userId: 'user-1',
    );
    const secondPlant = Plant(
      id: 'plant-history-2',
      name: 'Tomato Two',
      location: 'Balcony',
      plantedDate: '2026-10-01',
      lastInspectionDate: 'Belum ada pemeriksaan',
      status: 'Sehat',
      userId: 'user-2',
    );
    await plantRepository.create(firstPlant);
    await plantRepository.create(secondPlant);

    Future<void> saveScan({
      required String id,
      required String userId,
      required String plantId,
    }) {
      return appDatabase.saveScanResult(
        ScanRecordModel(
          id: id,
          userId: userId,
          plantId: plantId,
          diseaseName: 'Healthy',
          confidence: 0.95,
          localImagePath: '/tmp/$id.jpg',
          scannedAt: DateTime.utc(2026, 10, 23),
        ),
      );
    }

    await saveScan(id: 'scan-owner', userId: 'user-1', plantId: firstPlant.id);
    await saveScan(
      id: 'scan-other-user',
      userId: 'user-2',
      plantId: secondPlant.id,
    );
    final inspectedPlant = await plantRepository.getById(
      secondPlant.id,
      userId: 'user-2',
    );
    expect(inspectedPlant?.status, 'Sehat');
    expect(inspectedPlant?.lastInspectionDate, '23 Okt 2026');

    await expectLater(
      saveScan(
        id: 'scan-cross-account',
        userId: 'user-2',
        plantId: firstPlant.id,
      ),
      throwsStateError,
    );

    final scans = await appDatabase.getScansByPlantId(firstPlant.id, 'user-1');
    final otherUserScans = await appDatabase.getScansByUser('user-2');

    expect(scans.map((scan) => scan.id), ['scan-owner']);
    expect(scans.single.plantName, firstPlant.name);
    expect(scans.single.plantLocation, firstPlant.location);
    expect(otherUserScans.single.id, 'scan-other-user');
    expect(otherUserScans.single.plantName, secondPlant.name);
  });

  test('migrates legacy v3 indonesian schema to v2 tables', () async {
    final databasePath = path.join(tempDirectory.path, 'legacy_v3.db');
    final oldDatabase = await databaseFactoryFfi.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: 3,
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE pengguna (id_pengguna TEXT PRIMARY KEY)',
          );
          await db.execute(
            'CREATE TABLE tanaman (id_tanaman TEXT PRIMARY KEY)',
          );
          await db.execute(
            'CREATE TABLE penyakit (id_penyakit TEXT PRIMARY KEY)',
          );
        },
      ),
    );
    await oldDatabase.close();

    final migratedDb = AppDatabase.forTesting(
      databaseFactory: databaseFactoryFfi,
      databasePath: databasePath,
    );
    addTearDown(migratedDb.close);

    final db = await migratedDb.database;
    final names = (await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    )).map((row) => row['name']).toSet();

    expect(names, containsAll({'plants', 'scans', 'sync_queue', 'app_meta'}));
    expect(names, isNot(contains('pengguna')));
    expect(names, isNot(contains('tanaman')));
  });

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
