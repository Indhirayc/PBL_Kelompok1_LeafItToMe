import 'dart:async';

import 'package:flutter/foundation.dart';

import '../datasources/local/app_database.dart';
import '../models/scan_record_model.dart';
import '../../core/sync/sync_manager.dart';

class ScanRepository {
  final AppDatabase _localDb;
  final SyncManager _syncManager;

  ScanRepository({AppDatabase? localDb, SyncManager? syncManager})
    : _localDb = localDb ?? AppDatabase.instance,
      _syncManager = syncManager ?? SyncManager();

  Future<void> saveScanResult(ScanRecordModel record) async {
    await _localDb.saveScanResult(record);
    unawaited(
      _syncManager
          .syncPendingRecords(record.userId)
          .then<void>(
            (result) {
              if (result.hasFailures) {
                debugPrint(
                  '${result.failedCount} scan belum tersinkronisasi: '
                  '${result.errors.join('; ')}',
                );
              }
            },
            onError: (Object error, StackTrace stackTrace) {
              debugPrint('Sinkronisasi otomatis gagal: $error\n$stackTrace');
            },
          ),
    );
  }

  Future<List<ScanRecordModel>> getUserHistory(String userId) async {
    return await _localDb.getScansByUser(userId);
  }

  Future<List<ScanRecordModel>> getScansByPlantId(
    String plantId,
    String userId,
  ) async {
    return _localDb.getScansByPlantId(plantId, userId);
  }

  Future<List<ScanRecordModel>> getUnsyncedScans(String userId) {
    return _localDb.getUnsyncedScans(userId);
  }

  Future<SyncBatchResult> triggerSync(String userId) {
    return _syncManager.syncPendingRecords(userId);
  }

  Future<void> deleteScan(String id) async {
    await _localDb.deleteScan(id);
  }
}
