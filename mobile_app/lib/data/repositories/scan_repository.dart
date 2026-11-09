import '../datasources/local/app_database.dart';
import '../models/scan_record_model.dart';
import '../../core/sync/sync_manager.dart';

class ScanRepository {
  final AppDatabase _localDb;
  final SyncManager _syncManager;

  ScanRepository({
    AppDatabase? localDb,
    SyncManager? syncManager,
  })  : _localDb = localDb ?? AppDatabase.instance,
        _syncManager = syncManager ?? SyncManager();

  Future<void> saveScanResult(ScanRecordModel record) async {
    await _localDb.insertScan(record);
    _syncManager.syncPendingRecords(record.userId).catchError((_) {});
  }

  Future<List<ScanRecordModel>> getUserHistory(String userId) async {
    return await _localDb.getScansByUser(userId);
  }

  Future<void> triggerSync(String userId) async {
    await _syncManager.syncPendingRecords(userId);
  }
}
