import '../../../../core/errors/failures.dart';
import '../entities/detection.dart';
import '../repositories/detection_repository.dart';

/// Mengambil seluruh riwayat scan (terbaru lebih dulu).
class GetDetections {
  const GetDetections(this._repository);

  final DetectionRepository _repository;

  Future<({List<Detection> detections, Failure? failure})> call() {
    return _repository.getDetections();
  }
}