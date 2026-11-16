// ignore_for_file: prefer_initializing_formals

import '../../data/datasources/local/app_database.dart';
import '../../data/datasources/remote/cloudinary_source.dart';
import '../../data/datasources/remote/firestore_scan_source.dart';
import '../../data/datasources/remote/scan_api_source.dart';
import '../../data/models/scan_record_model.dart';

class SyncManager {
  SyncManager({
    AppDatabase? localDb,
    ScanApiSource? apiSource,
    CloudinarySource? cloudinarySource,
    FirestoreScanSource? firestoreSource,
  })  : _localDb = localDb ?? AppDatabase.instance,
        _apiSource = apiSource,
        _cloudinarySource = cloudinarySource ?? CloudinarySource(),
        _firestoreSource = firestoreSource ?? FirestoreScanSource();

  final AppDatabase _localDb;
  final ScanApiSource? _apiSource;
  final CloudinarySource _cloudinarySource;
  final FirestoreScanSource _firestoreSource;

  Future<void> syncPendingRecords(String userId) async {
    final List<ScanRecordModel> pendingScans = await _localDb.getUnsyncedScans(
      userId,
    );

    if (pendingScans.isEmpty) return;

    for (final scan in pendingScans) {
      try {
        String? cloudImageUrl = scan.cloudImageUrl;

        // 1. Unggah gambar ke Cloudinary jika belum memiliki URL cloud
        if (scan.localImagePath.isNotEmpty &&
            (cloudImageUrl == null || cloudImageUrl.isEmpty)) {
          try {
            final uploadResult = await _cloudinarySource.uploadScanImage(
              userId: scan.userId,
              localPath: scan.localImagePath,
            );
            cloudImageUrl = uploadResult['secure_url'];
          } catch (_) {
            // Upload foto gagal: jika offline, lanjutkan atau lewati jika foto esensial
          }
        }

        // 2. Simpan metadata ke Cloud Firestore
        final updatedRecord = scan.copyWith(
          cloudImageUrl: cloudImageUrl,
          isSynced: true,
        );
        await _firestoreSource.saveScanRecord(updatedRecord);

        // 3. Sinkronkan ke API backend jika tersedia (opsional/legacy)
        if (_apiSource != null) {
          try {
            await _apiSource.saveScan(updatedRecord);
          } catch (_) {}
        }

        // 4. Tandai record sebagai tersinkronisasi di SQLite lokal
        await _localDb.markAsSynced(scan.id, cloudImageUrl);
      } catch (_) {
        // Lewati record yang gagal agar tidak menghambat batch lainnya.
        continue;
      }
    }
  }
}
