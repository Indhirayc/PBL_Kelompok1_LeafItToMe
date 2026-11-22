import 'dart:async';

import 'package:flutter/foundation.dart';

import '../datasources/local/app_database.dart';
import '../datasources/remote/firestore_scan_source.dart';
import '../models/scan_record_model.dart';
import '../../core/sync/sync_manager.dart';

class ScanRepository {
  final AppDatabase _localDb;
  final SyncManager _syncManager;
  final FirestoreScanSource _firestoreSource;

  ScanRepository({
    AppDatabase? localDb,
    SyncManager? syncManager,
    FirestoreScanSource? firestoreSource,
  }) : _localDb = localDb ?? AppDatabase.instance,
       _syncManager = syncManager ?? SyncManager(),
       _firestoreSource = firestoreSource ?? FirestoreScanSource();

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

  /// Pulihkan riwayat scan dari Firestore (dipakai saat HP baru / data lokal
  /// kosong). Scan yang sudah ada di lokal dilewati agar tidak duplikat;
  /// hasil pulihan langsung ditandai `synced` karena datanya berasal dari
  /// cloud, lalu foto ditarik dari `cloud_image_url` oleh cache hybrid.
  /// Mengembalikan jumlah record yang berhasil dipulihkan.
  Future<int> restoreFromCloud(String userId) async {
    final remote = await _firestoreSource.getUserScans(userId);
    if (remote.isEmpty) return 0;

    final local = await _localDb.getScansByUser(userId);
    final localIds = local.map((scan) => scan.id).toSet();

    var restored = 0;
    for (final scan in remote) {
      if (localIds.contains(scan.id)) continue;
      await _localDb.insertScan(scan);
      if (scan.isSynced) {
        await _localDb.markAsSynced(scan.id, scan.cloudImageUrl);
      }
      restored++;
    }

    debugPrint('ScanRepository: $restored riwayat dipulihkan dari cloud.');
    return restored;
  }
}
