import '../../data/datasources/local/app_database.dart';
import '../../data/datasources/remote/cloudinary_source.dart';
import '../../data/datasources/remote/firestore_scan_source.dart';
import '../../data/models/scan_record_model.dart';

class SyncManager {
  final AppDatabase _localDb;
  final CloudinarySource _cloudinarySource;
  final FirestoreScanSource _firestoreSource;

  SyncManager({
    AppDatabase? localDb,
    CloudinarySource? cloudinarySource,
    FirestoreScanSource? firestoreSource,
  }) : _localDb = localDb ?? AppDatabase.instance,
       _cloudinarySource = cloudinarySource ?? CloudinarySource(),
       _firestoreSource = firestoreSource ?? FirestoreScanSource();

  Future<void> syncPendingRecords(String userId) async {
    final List<ScanRecordModel> pendingScans = await _localDb.getUnsyncedScans(
      userId,
    );

    if (pendingScans.isEmpty) return;

    for (final scan in pendingScans) {
      try {
        // Upload gambar daun ke Cloudinary
        final uploadResult = await _cloudinarySource.uploadScanImage(
          userId: scan.userId,
          localPath: scan.localImagePath,
        );

        final String downloadUrl = uploadResult['secure_url']!;

        final updatedRecord = scan.copyWith(
          cloudImageUrl: downloadUrl,
          isSynced: true,
        );

        // Simpan metadata ke Firestore & tandai sinkron di SQLite lokal
        await _firestoreSource.saveScanRecord(updatedRecord);
        await _localDb.markAsSynced(scan.id, downloadUrl);
      } catch (e) {
        // Lewati record yang gagal agar tidak menghambat item berikutnya
        continue;
      }
    }
  }
}
