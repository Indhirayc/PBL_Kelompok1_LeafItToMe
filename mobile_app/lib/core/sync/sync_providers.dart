import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/cloudinary_source.dart';
import '../providers/database_providers.dart';
import 'sync_manager.dart';

final Provider<CloudinarySource> cloudinarySourceProvider =
    Provider<CloudinarySource>((ref) => CloudinarySource());

final Provider<SyncManager> syncManagerProvider = Provider<SyncManager>(
  (ref) => SyncManager(
    localDb: ref.watch(databaseProvider),
    cloudinarySource: ref.watch(cloudinarySourceProvider),
  ),
);
