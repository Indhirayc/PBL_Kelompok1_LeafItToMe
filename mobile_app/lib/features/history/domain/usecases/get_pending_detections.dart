import '../../../../core/errors/failures.dart';
import '../entities/detection.dart';
import '../repositories/detection_repository.dart';

/// Mengambil riwayat scan yang masih menunggu sinkronisasi (antrian offline).
class GetPendingDetections {
  const GetPendingDetections(this._repository);

  final DetectionRepository _repository;

  Future<({List<Detection> detections, Failure? failure})> call() {
    return _repository.getPendingDetections();
  }
}