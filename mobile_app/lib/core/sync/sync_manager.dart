// ignore_for_file: prefer_initializing_formals

import 'package:flutter/foundation.dart';

import '../../data/datasources/local/app_database.dart';
import '../../data/datasources/remote/cloudinary_source.dart';
import '../../data/datasources/remote/firestore_scan_source.dart';
import '../../data/datasources/remote/scan_api_source.dart';

class SyncBatchResult {
  const SyncBatchResult({
    required this.syncedIds,
    required this.failedIds,
    this.errors = const [],
  });

  final List<String> syncedIds;
  final List<String> failedIds;
  final List<String> errors;

  int get syncedCount => syncedIds.length;
  int get failedCount => failedIds.length;
  bool get hasFailures => failedIds.isNotEmpty;

  factory SyncBatchResult.offline(Iterable<String> pendingIds) {
    return SyncBatchResult(
      syncedIds: const [],
      failedIds: pendingIds.toList(),
      errors: const ['Mode offline aktif. Hubungkan perangkat lalu coba lagi.'],
    );
  }

  factory SyncBatchResult.failed(Iterable<String> pendingIds, Object error) {
    return SyncBatchResult(
      syncedIds: const [],
      failedIds: pendingIds.toList(),
      errors: [error.toString()],
    );
  }
}

class SyncManager {
  SyncManager({
    AppDatabase? localDb,
    ScanApiSource? apiSource,
    ScanImageUploader? cloudinarySource,
    FirestoreScanWriter? firestoreSource,
  }) : _localDb = localDb ?? AppDatabase.instance,
       _apiSource = apiSource,
       _cloudinarySource = cloudinarySource ?? CloudinarySource(),
       _firestoreSource = firestoreSource ?? FirestoreScanSource();

  final AppDatabase _localDb;
  final ScanApiSource? _apiSource;
  final ScanImageUploader _cloudinarySource;
  final FirestoreScanWriter _firestoreSource;

  Future<SyncBatchResult> syncPendingRecords(String userId) async {
    final pendingScans = await _localDb.getUnsyncedScans(userId);
    final syncedIds = <String>[];
    final failedIds = <String>[];
    final errors = <String>[];

    for (final scan in pendingScans) {
      try {
        var cloudImageUrl = scan.cloudImageUrl;
        if (scan.localImagePath.isNotEmpty &&
            (cloudImageUrl == null || cloudImageUrl.isEmpty)) {
          final uploadResult = await _cloudinarySource.uploadScanImage(
            userId: scan.userId,
            localPath: scan.localImagePath,
          );
          cloudImageUrl = uploadResult['secure_url'];
          if (cloudImageUrl == null || cloudImageUrl.isEmpty) {
            throw StateError('Cloudinary tidak mengembalikan URL gambar.');
          }
        }

        final updatedRecord = scan.copyWith(
          cloudImageUrl: cloudImageUrl,
          isSynced: true,
        );
        await _firestoreSource.saveScanRecord(updatedRecord);

        if (_apiSource != null) {
          try {
            await _apiSource.saveScan(updatedRecord);
          } catch (error) {
            debugPrint(
              'Sinkronisasi API tambahan gagal untuk ${scan.id}: $error',
            );
          }
        }

        final updatedCount = await _localDb.markAsSynced(
          scan.id,
          cloudImageUrl,
        );
        if (updatedCount != 1) {
          throw StateError(
            'Status lokal scan ${scan.id} tidak dapat diperbarui.',
          );
        }
        syncedIds.add(scan.id);
      } catch (error, stackTrace) {
        debugPrint('Sinkronisasi scan ${scan.id} gagal: $error\n$stackTrace');
        failedIds.add(scan.id);
        errors.add('${scan.id}: $error');
        try {
          await _localDb.syncQueueDao.recordFailure(
            entityType: 'scan',
            entityId: scan.id,
            operation: 'upsert',
            error: error.toString(),
          );
        } catch (queueError, queueStackTrace) {
          debugPrint(
            'Gagal mencatat retry scan ${scan.id}: '
            '$queueError\n$queueStackTrace',
          );
        }
      }
    }

    return SyncBatchResult(
      syncedIds: syncedIds,
      failedIds: failedIds,
      errors: errors,
    );
  }
}
