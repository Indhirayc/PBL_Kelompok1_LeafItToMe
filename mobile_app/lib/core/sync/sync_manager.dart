import '../../data/datasources/remote/cloudinary_source.dart';
import '../../data/datasources/local/app_database.dart';
import '../../data/models/scan_record_model.dart';

class SyncManager {
  final AppDatabase localDb;
  final ScanImageUploader cloudinarySource;

  SyncManager({
    AppDatabase? localDb,
    ScanImageUploader? cloudinarySource,
  })  : localDb = localDb ?? AppDatabase.instance,
        cloudinarySource = cloudinarySource ?? CloudinarySource();

  // Logika sinkronisasi upload gambar ke Cloudinary & simpan ke database
  Future<SyncBatchResult> syncPendingRecords(String userId) async {
    // Implementasi sync lokal Anda menggunakan SQLite & Cloudinary
    List<ScanRecordModel> unsynced = await localDb.getUnsyncedScans(userId);
    List<String> syncedIds = [];
    List<String> failedIds = [];
    List<String> errors = [];

    for (var scan in unsynced) {
      try {
        // 1. Upload ke Cloudinary
        final uploadResult = await cloudinarySource.uploadScanImage(
          userId: userId,
          localPath: scan.localImagePath,
        );
        final secureUrl = uploadResult['secure_url'];

        // 2. Tandai tersinkronisasi di SQLite lokal
        await localDb.markAsSynced(scan.id, secureUrl);
        syncedIds.add(scan.id);
      } catch (e) {
        failedIds.add(scan.id);
        errors.add(e.toString());
      }
    }

    return SyncBatchResult(
      syncedIds: syncedIds,
      failedIds: failedIds,
      errors: errors,
    );
  }
}

class SyncBatchResult {
  final List<String> syncedIds;
  final List<String> failedIds;
  final List<String> errors;

  const SyncBatchResult({
    required this.syncedIds,
    required this.failedIds,
    this.errors = const [],
  });

  factory SyncBatchResult.failed(List<String> failedIds, Object error) {
    return SyncBatchResult(
      syncedIds: const [],
      failedIds: failedIds,
      errors: [error.toString()],
    );
  }

  bool get hasFailures => failedIds.isNotEmpty;
  int get failedCount => failedIds.length;
  int get syncedCount => syncedIds.length;
  bool get isSuccess => failedIds.isEmpty;
}
