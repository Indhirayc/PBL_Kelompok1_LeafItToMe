import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/data/datasources/local/app_database.dart';
import 'package:mobile_app/data/models/scan_record_model.dart';
import 'package:mobile_app/data/repositories/plant_repository.dart';
import 'package:mobile_app/features/history/data/history_data.dart';
import 'package:mobile_app/features/plants/models/plant.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tempDirectory;
  late AppDatabase appDatabase;
  late PlantRepository plantRepository;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'leafittome_history_',
    );
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

  test('converts confidence fractions to a bounded percentage', () {
    ScanRecordModel scan(double confidence) => ScanRecordModel(
      id: 'scan-$confidence',
      userId: 'user-1',
      diseaseName: 'Healthy',
      confidence: confidence,
      localImagePath: '/tmp/leaf.jpg',
      scannedAt: DateTime.utc(2026, 10, 23),
    );

    expect(HistoryData.recordFromScan(scan(0.954)).accuracy, 95);
    expect(HistoryData.recordFromScan(scan(-0.2)).accuracy, 0);
    expect(HistoryData.recordFromScan(scan(1.2)).accuracy, 100);
  });

  test('history records are filtered by account', () {
    final firstAccount = HistoryRecord(
      id: 'account-1-scan',
      plantId: 'shared-test-plant',
      diseaseName: 'Healthy',
      latinName: '',
      date: DateTime.utc(2026, 10, 23),
      accuracy: 95,
      isHealthy: true,
      note: '',
      userId: 'account-1',
    );
    final secondAccount = HistoryRecord(
      id: 'account-2-scan',
      plantId: 'shared-test-plant',
      diseaseName: 'Late Blight',
      latinName: '',
      date: DateTime.utc(2026, 10, 24),
      accuracy: 90,
      isHealthy: false,
      note: '',
      userId: 'account-2',
    );
    HistoryData.records.addAll([firstAccount, secondAccount]);
    addTearDown(
      () => HistoryData.records.removeWhere(
        (record) =>
            record.id == firstAccount.id || record.id == secondAccount.id,
      ),
    );

    expect(
      HistoryData.recordsByPlantId(
        'shared-test-plant',
        userId: 'account-1',
      ).map((record) => record.id),
      [firstAccount.id],
    );
    expect(
      HistoryData.recordsByPlantId(
        'shared-test-plant',
        userId: 'account-2',
      ).map((record) => record.id),
      [secondAccount.id],
    );
  });

  test('sync status updates only records owned by the matching account', () {
    final firstAccount = HistoryRecord(
      id: 'sync-account-1',
      plantId: 'plant-1',
      diseaseName: 'Late Blight',
      latinName: '',
      date: DateTime.utc(2026, 10, 23),
      accuracy: 90,
      isHealthy: false,
      note: '',
      isSynced: false,
      userId: 'account-1',
    );
    final secondAccount = HistoryRecord(
      id: 'sync-account-2',
      plantId: 'plant-2',
      diseaseName: 'Late Blight',
      latinName: '',
      date: DateTime.utc(2026, 10, 23),
      accuracy: 90,
      isHealthy: false,
      note: '',
      isSynced: false,
      userId: 'account-2',
    );
    HistoryData.records.addAll([firstAccount, secondAccount]);
    addTearDown(
      () => HistoryData.records.removeWhere(
        (record) =>
            record.id == firstAccount.id || record.id == secondAccount.id,
      ),
    );

    HistoryData.markScansSynced(
      userId: 'account-1',
      scanIds: [firstAccount.id, secondAccount.id],
    );

    expect(
      HistoryData.records
          .singleWhere((record) => record.id == firstAccount.id)
          .isSynced,
      isTrue,
    );
    expect(
      HistoryData.records
          .singleWhere((record) => record.id == secondAccount.id)
          .isSynced,
      isFalse,
    );
  });

  test('plantById resolves plants loaded from SQLite', () async {
    const plant = Plant(
      id: 'history-dynamic-plant',
      name: 'Tomat Baru',
      location: 'Balkon',
      plantedDate: '12 Okt 2026',
      lastInspectionDate: 'Belum ada pemeriksaan',
      status: 'Sehat',
    );
    await plantRepository.create(plant);

    await HistoryData.loadPersistedPlants(repository: plantRepository);

    final loadedPlant = HistoryData.plantById(plant.id);
    expect(loadedPlant?.name, plant.name);
    expect(loadedPlant?.location, plant.location);
  });
}
