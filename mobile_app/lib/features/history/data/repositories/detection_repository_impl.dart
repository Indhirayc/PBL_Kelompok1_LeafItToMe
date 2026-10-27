import '../../../../core/errors/failures.dart';
import '../../domain/entities/detection.dart';
import '../../domain/repositories/detection_repository.dart';
import '../datasources/detection_local_datasource.dart';
import '../models/detection_model.dart';

/// Implementasi SQLite dari [DetectionRepository].
class DetectionRepositoryImpl implements DetectionRepository {
  const DetectionRepositoryImpl({required this.localDataSource});

  final DetectionLocalDataSource localDataSource;

  @override
  Future<({List<Detection> detections, Failure? failure})> getDetections() async {
    try {
      final models = await localDataSource.getDetections();
      return (
        detections: models.map((model) => model.toEntity()).toList(growable: false),
        failure: null,
      );
    } catch (error) {
      return (
        detections: const <Detection>[],
        failure: LocalFailure('Gagal membaca riwayat scan: $error'),
      );
    }
  }

  @override
  Future<({List<Detection> detections, Failure? failure})>
  getPendingDetections() async {
    try {
      final models = await localDataSource.getPendingDetections();
      return (
        detections: models.map((model) => model.toEntity()).toList(growable: false),
        failure: null,
      );
    } catch (error) {
      return (
        detections: const <Detection>[],
        failure: LocalFailure('Gagal membaca antrian sinkronisasi: $error'),
      );
    }
  }

  @override
  Future<({Detection? detection, Failure? failure})> saveDetection(
    Detection detection, {
    required String userEmail,
    required String userName,
  }) async {
    try {
      await localDataSource.insertDetection(
        DetectionModel.fromEntity(detection),
        userEmail: userEmail,
        userName: userName,
      );
      return (detection: detection, failure: null);
    } catch (error) {
      return (
        detection: null,
        failure: LocalFailure('Gagal menyimpan hasil scan: $error'),
      );
    }
  }

  @override
  Future<({int synced, Failure? failure})> markSynced({
    required String code,
    required DateTime syncedAt,
  }) async {
    try {
      final rows = await localDataSource.markSynced(code, syncedAt);
      return (synced: rows, failure: null);
    } catch (error) {
      return (
        synced: 0,
        failure: LocalFailure('Gagal menandai sinkronisasi: $error'),
      );
    }
  }
}