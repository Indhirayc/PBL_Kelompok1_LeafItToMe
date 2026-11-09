import '../../data/datasources/local/app_database.dart';
import '../../data/datasources/remote/scan_api_source.dart';
import '../../data/models/scan_record_model.dart';
import '../network/api_client.dart';

class SyncManager {
  SyncManager({AppDatabase? localDb, ScanApiSource? apiSource})
    : _localDb = localDb ?? AppDatabase.instance,
      _apiSource = apiSource ?? ScanApiSourceImpl(createApiClient());

  final AppDatabase _localDb;
  final ScanApiSource _apiSource;

  Future<void> syncPendingRecords(String userId) async {
    final List<ScanRecordModel> pendingScans = await _localDb.getUnsyncedScans(
      userId,
    );

    if (pendingScans.isEmpty) return;

    for (final scan in pendingScans) {
      try {
        await _apiSource.saveScan(scan);

        String? cloudImageUrl;
        if (scan.localImagePath.isNotEmpty) {
          cloudImageUrl = await _apiSource.uploadScanImage(
            scan.id,
            scan.localImagePath,
          );
        }

        await _localDb.markAsSynced(scan.id, cloudImageUrl);
      } catch (_) {
        // Lewati record yang gagal agar tidak menghambat batch lainnya.
        continue;
      }
    }
  }
}
