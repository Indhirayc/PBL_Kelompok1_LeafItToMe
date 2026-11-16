import 'package:mobile_app/core/sync/sync_manager.dart';
import 'package:mobile_app/data/datasources/remote/firestore_scan_source.dart';
import 'package:mobile_app/data/models/scan_record_model.dart';
import 'package:mobile_app/data/repositories/scan_repository.dart';

class FakeScanRepository extends ScanRepository {
  FakeScanRepository({
    this.pendingScans = const [],
    this.syncResult = const SyncBatchResult(syncedIds: [], failedIds: []),
  }) : super(syncManager: _FakeSyncManager(syncResult));

  final List<ScanRecordModel> pendingScans;
  final SyncBatchResult syncResult;
  int syncCallCount = 0;

  @override
  Future<List<ScanRecordModel>> getUnsyncedScans(String userId) async =>
      pendingScans;

  @override
  Future<SyncBatchResult> triggerSync(String userId) async {
    syncCallCount++;
    return syncResult;
  }
}

class _FakeSyncManager extends SyncManager {
  _FakeSyncManager(this.result)
    : super(firestoreSource: _FakeFirestoreWriter());

  final SyncBatchResult result;

  @override
  Future<SyncBatchResult> syncPendingRecords(String userId) async => result;
}

class _FakeFirestoreWriter implements FirestoreScanWriter {
  @override
  Future<void> saveScanRecord(ScanRecordModel record) async {}
}
