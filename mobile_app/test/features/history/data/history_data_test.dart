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
