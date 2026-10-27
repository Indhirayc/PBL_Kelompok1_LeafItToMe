import '../../../../core/errors/failures.dart';
import '../entities/detection.dart';
import '../repositories/detection_repository.dart';

/// Menyimpan satu hasil scan ke database lokal.
///
/// Baris tersimpan dengan `is_synced = false` bila belum diunggah, sehingga
/// masuk antrian sinkronisasi saat perangkat kembali online.
class SaveDetection {
  const SaveDetection(this._repository);

  final DetectionRepository _repository;

  Future<({Detection? detection, Failure? failure})> call(
    Detection detection, {
    required String userEmail,
    required String userName,
  }) {
    return _repository.saveDetection(
      detection,
      userEmail: userEmail,
      userName: userName,
    );
  }
}