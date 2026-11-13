import '../../data/datasources/local/app_database.dart';
import '../../data/datasources/remote/cloudinary_source.dart';
import '../../data/datasources/remote/firestore_scan_source.dart';
import '../../data/datasources/remote/scan_api_source.dart';
import '../../data/models/scan_record_model.dart';
import '../network/api_client.dart';

class SyncManager {
  SyncManager({
    AppDatabase? localDb,
    ScanApiSource? apiSource,
    CloudinarySource? cloudinarySource,
    FirestoreScanSource? firestoreSource,
  })  : _localDb = localDb ?? AppDatabase.instance,
        _apiSource = apiSource ?? ScanApiSourceImpl(createApiClient()),
        _cloudinarySource = cloudinarySource,
        _firestoreSource = firestoreSource;

  final AppDatabase _localDb;
  final ScanApiSource _apiSource;
  final CloudinarySource? _cloudinarySource;
  final FirestoreScanSource? _firestoreSource;

  Future<void> syncPendingRecords(String userId) async {
    final List<ScanRecordModel> pendingScans = await _localDb.getUnsyncedScans(
      userId,
    );

    if (pendingScans.isEmpty) return;

    for (final scan in pendingScans) {
      try {
        String? cloudImageUrl = scan.cloudImageUrl;

        // 1. Jika ada CloudinarySource, unggah gambar ke Cloudinary
        if (_cloudinarySource != null && scan.localImagePath.isNotEmpty) {
          try {
            final uploadResult = await _cloudinarySource!.uploadScanImage(
              userId: scan.userId,
              localPath: scan.localImagePath,
            );
            cloudImageUrl = uploadResult['secure_url'];
          } catch (_) {}
        }

        // 2. Jika ada FirestoreScanSource, simpan metadata ke Cloud Firestore
        if (_firestoreSource != null) {
          try {
            final updatedRecord = scan.copyWith(
              cloudImageUrl: cloudImageUrl,
              isSynced: true,
            );
            await _firestoreSource!.saveScanRecord(updatedRecord);
          } catch (_) {}
        }

        // 3. Sinkronkan ke API backend jika tersedia
        try {
          await _apiSource.saveScan(scan);
          if (cloudImageUrl == null && scan.localImagePath.isNotEmpty) {
            cloudImageUrl = await _apiSource.uploadScanImage(
              scan.id,
              scan.localImagePath,
            );
          }
        } catch (_) {}

        // 4. Tandai record sebagai tersinkronisasi di SQLite lokal
        await _localDb.markAsSynced(scan.id, cloudImageUrl);
      } catch (_) {
        // Lewati record yang gagal agar tidak menghambat batch lainnya.
        continue;
      }
    }
  }
}
