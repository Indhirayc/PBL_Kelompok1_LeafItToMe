import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/scan_api_source.dart';
import '../providers/network_providers.dart';
import 'sync_manager.dart';

final Provider<ScanApiSource> scanApiSourceProvider = Provider<ScanApiSource>(
  (ref) => ScanApiSourceImpl(
    ref.watch(dioProvider),
    apiConfig: ref.watch(apiConfigProvider),
  ),
);

final Provider<SyncManager> syncManagerProvider = Provider<SyncManager>(
  (ref) => SyncManager(apiSource: ref.watch(scanApiSourceProvider)),
);
