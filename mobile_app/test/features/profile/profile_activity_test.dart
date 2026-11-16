import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/providers/database_providers.dart';
import 'package:mobile_app/core/sync/sync_manager.dart';
import 'package:mobile_app/data/models/scan_record_model.dart';
import 'package:mobile_app/data/repositories/scan_repository.dart';
import 'package:mobile_app/features/profile/presentation/pages/profile_page.dart';

class _MemoryScanRepository implements ScanRepository {
  _MemoryScanRepository(this.scans);

  final List<ScanRecordModel> scans;
  String? requestedUserId;

  @override
  Future<List<ScanRecordModel>> getUserHistory(String userId) async {
    requestedUserId = userId;
    return scans;
  }

  @override
  Future<void> deleteScan(String id) async {}

  @override
  Future<List<ScanRecordModel>> getScansByPlantId(
    String plantId,
    String userId,
  ) async => [];

  @override
  Future<List<ScanRecordModel>> getUnsyncedScans(String userId) async => [];

  @override
  Future<void> saveScanResult(ScanRecordModel record) async {}

  @override
  Future<SyncBatchResult> triggerSync(String userId) async =>
      const SyncBatchResult(syncedIds: [], failedIds: []);
}

ScanRecordModel _scan(String id, String diseaseName) => ScanRecordModel(
  id: id,
  userId: 'user-local',
  diseaseName: diseaseName,
  confidence: 0.9,
  localImagePath: '',
  scannedAt: DateTime(2026, 9, 25),
);

void main() {
  test('activity stats count disease and healthy scans from history', () async {
    final repository = _MemoryScanRepository([
      _scan('scan-1', 'Bacterial_Spot'),
      _scan('scan-2', 'P005'),
      _scan('scan-3', 'Late_Blight'),
    ]);
    final container = ProviderContainer(
      overrides: [scanRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final stats = await container.read(plantActivityStatsProvider.future);

    expect(stats.totalScans, 3);
    expect(stats.diseasedScans, 2);
    expect(stats.healthyScans, 1);
    expect(repository.requestedUserId, 'user-local');
  });

  testWidgets('profile renders scan counts from activity stats', (
    tester,
  ) async {
    final repository = _MemoryScanRepository([
      _scan('scan-1', 'Bacterial_Spot'),
      _scan('scan-2', 'P005'),
      _scan('scan-3', 'Late_Blight'),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [scanRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: ProfilePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });
}
