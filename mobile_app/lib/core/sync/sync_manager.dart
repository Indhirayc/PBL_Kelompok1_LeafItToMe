import 'dart:io';

import 'package:flutter/foundation.dart';

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
        // 1. Simpan metadata scan terlebih dahulu agar tidak hilang
        //    walau upload gambar gagal.
        await _firestoreSource.saveScanRecord(scan);

        // 2. Upload gambar hanya bila path file lokal benar-benar ada.
        String? cloudImageUrl;
        final localFile = File(scan.localImagePath);
        if (await localFile.exists()) {
          final uploadResult = await _cloudinarySource.uploadScanImage(
            userId: scan.userId,
            localPath: scan.localImagePath,
          );
          cloudImageUrl = uploadResult['secure_url'];
        } else {
          debugPrint(
            'SyncManager: file lokal tidak ditemukan, upload gambar '
            'dilewati (${scan.localImagePath})',
          );
        }

        // 3. Perbarui URL gambar di Firestore & tandai tersinkron di SQLite.
        if (cloudImageUrl != null) {
          await _firestoreSource.saveScanRecord(
            scan.copyWith(cloudImageUrl: cloudImageUrl, isSynced: true),
          );
        }
        await _localDb.markAsSynced(scan.id, cloudImageUrl);
      } catch (e) {
        // Lewati record yang gagal agar tidak menghambat item berikutnya.
        debugPrint('SyncManager: sync gagal untuk ${scan.id}: $e');
        continue;
      }
    }
  }
}
