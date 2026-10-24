import '../../data/datasources/local/app_database.dart';
import '../../data/datasources/remote/firebase_storage_source.dart';
import '../../data/datasources/remote/firestore_scan_source.dart';
import '../../data/models/scan_record_model.dart';

class SyncManager {
  final AppDatabase _localDb;
  final FirebaseStorageSource _storageSource;
  final FirestoreScanSource _firestoreSource;

  SyncManager({
    AppDatabase? localDb,
    FirebaseStorageSource? storageSource,
    FirestoreScanSource? firestoreSource,
  })  : _localDb = localDb ?? AppDatabase.instance,
        _storageSource = storageSource ?? FirebaseStorageSource(),
        _firestoreSource = firestoreSource ?? FirestoreScanSource();

  Future<void> syncPendingRecords(String userId) async {
    final List<ScanRecordModel> pendingScans =
        await _localDb.getUnsyncedScans(userId);

    if (pendingScans.isEmpty) return;

    for (final scan in pendingScans) {
      try {
        final String downloadUrl = await _storageSource.uploadLeafImage(
          userId: scan.userId,
          scanId: scan.id,
          localPath: scan.localImagePath,
        );

        final updatedRecord = scan.copyWith(
          cloudImageUrl: downloadUrl,
          isSynced: true,
        );

        await _firestoreSource.saveScanRecord(updatedRecord);
        await _localDb.markAsSynced(scan.id, downloadUrl);
      } catch (e) {
        // Lewati record yang gagal agar tidak menghambat batch lainnya
        continue;
      }
    }
  }
}
