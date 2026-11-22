import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/sync/sync_manager.dart';
import 'package:mobile_app/data/datasources/local/app_database.dart';
import 'package:mobile_app/data/datasources/remote/cloudinary_source.dart';
import 'package:mobile_app/data/models/scan_record_model.dart';
import 'package:mobile_app/data/repositories/plant_repository.dart';
import 'package:mobile_app/features/plants/models/plant.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tempDirectory;
  late AppDatabase appDatabase;
  late PlantRepository plantRepository;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('leafittome_sync_');
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

  test('keeps failed scans pending and reports only confirmed syncs', () async {
    const plant = Plant(
      id: 'sync-plant',
      name: 'Tomato',
      location: 'Garden',
      plantedDate: '2026-10-01',
      lastInspectionDate: 'Belum ada pemeriksaan',
      status: 'Sehat',
      userId: 'user-1',
    );
    await plantRepository.create(plant);

    final scans = [
      _makeScan('scan-success', '/local/success.jpg'),
      _makeScan('scan-upload-failure', '/local/missing.jpg'),
    ];
    for (final scan in scans) {
      await appDatabase.saveScanResult(scan);
    }

    final uploader = _FakeImageUploader(failPaths: {'/local/missing.jpg'});
    final manager = SyncManager(
      localDb: appDatabase,
      cloudinarySource: uploader,
    );

    final result = await manager.syncPendingRecords('user-1');

    expect(result.syncedIds, ['scan-success']);
    expect(result.failedIds, ['scan-upload-failure']);
    expect(result.errors, hasLength(1));

    expect(
      uploader.uploadedPaths,
      unorderedEquals(['/local/success.jpg', '/local/missing.jpg']),
    );
    expect(
      (await appDatabase.getUnsyncedScans('user-1')).map((scan) => scan.id),
      ['scan-upload-failure'],
    );
    expect(await appDatabase.syncQueueDao.getPending(), hasLength(1));
  });
}

ScanRecordModel _makeScan(String id, String localPath) => ScanRecordModel(
  id: id,
  userId: 'user-1',
  plantId: 'sync-plant',
  diseaseName: 'Late Blight',
  confidence: 0.9,
  localImagePath: localPath,
  scannedAt: DateTime.utc(2026, 11, 17),
);

class _FakeImageUploader implements ScanImageUploader {
  _FakeImageUploader({this.failPaths = const {}});

  final Set<String> failPaths;
  final List<String> uploadedPaths = [];

  @override
  Future<Map<String, String>> uploadScanImage({
    required String userId,
    required String localPath,
  }) async {
    uploadedPaths.add(localPath);
    if (failPaths.contains(localPath)) {
      throw StateError('Image upload failed');
    }
    return {'secure_url': 'https://example.com/${path.basename(localPath)}'};
  }
}
