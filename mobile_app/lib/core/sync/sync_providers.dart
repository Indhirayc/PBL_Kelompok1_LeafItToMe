import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/cloudinary_source.dart';
import '../../data/datasources/remote/firestore_scan_source.dart';
import '../../data/datasources/remote/scan_api_source.dart';
import '../providers/network_providers.dart';
import 'sync_manager.dart';

final Provider<CloudinarySource> cloudinarySourceProvider =
    Provider<CloudinarySource>((ref) => CloudinarySource());

final Provider<FirestoreScanSource> firestoreScanSourceProvider =
    Provider<FirestoreScanSource>((ref) => FirestoreScanSource());

final Provider<ScanApiSource> scanApiSourceProvider = Provider<ScanApiSource>(
  (ref) => ScanApiSourceImpl(
    ref.watch(dioProvider),
    apiConfig: ref.watch(apiConfigProvider),
  ),
);

final Provider<SyncManager> syncManagerProvider = Provider<SyncManager>(
  (ref) => SyncManager(
    cloudinarySource: ref.watch(cloudinarySourceProvider),
    firestoreSource: ref.watch(firestoreScanSourceProvider),
    apiSource: ref.watch(scanApiSourceProvider),
  ),
);
