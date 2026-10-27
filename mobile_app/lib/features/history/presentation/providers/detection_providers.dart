import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_providers.dart';
import '../../data/datasources/detection_local_datasource.dart';
import '../../data/repositories/detection_repository_impl.dart';
import '../../domain/entities/detection.dart';
import '../../domain/repositories/detection_repository.dart';
import '../../domain/usecases/get_detections.dart';
import '../../domain/usecases/get_pending_detections.dart';
import '../../domain/usecases/save_detection.dart';

/// Data layer: sumber data SQLite memakai pembuka database yang disuntikkan.
final detectionLocalDataSourceProvider = Provider<DetectionLocalDataSource>(
  (ref) => DetectionLocalDataSource(
    () => ref.watch(offlineDatabaseProvider.future),
  ),
);

/// Data layer: implementasi repository.
final detectionRepositoryProvider = Provider<DetectionRepository>(
  (ref) => DetectionRepositoryImpl(
    localDataSource: ref.watch(detectionLocalDataSourceProvider),
  ),
);

/// Domain layer: use case menerima abstraksi, bukan implementasi.
final getDetectionsProvider = Provider<GetDetections>(
  (ref) => GetDetections(ref.watch(detectionRepositoryProvider)),
);

final getPendingDetectionsProvider = Provider<GetPendingDetections>(
  (ref) => GetPendingDetections(ref.watch(detectionRepositoryProvider)),
);

final saveDetectionProvider = Provider<SaveDetection>(
  (ref) => SaveDetection(ref.watch(detectionRepositoryProvider)),
);

/// Presentation layer: state riwayat scan untuk UI.
final detectionsProvider = FutureProvider<List<Detection>>((ref) async {
  final result = await ref.watch(getDetectionsProvider).call();
  if (result.failure != null) {
    throw Exception(result.failure!.message);
  }
  return result.detections;
});