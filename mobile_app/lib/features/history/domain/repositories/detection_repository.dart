import '../../../../core/errors/failures.dart';
import '../entities/detection.dart';

/// Kontrak riwayat scan (deteksi) yang dibutuhkan domain.
///
/// Implementasi konkret (SQLite) hidup di layer data. Sukses/gagal ditandai
/// eksplisit lewat record agar exception tidak bocor ke presentation.
abstract interface class DetectionRepository {
  Future<({List<Detection> detections, Failure? failure})> getDetections();

  /// Riwayat yang belum diunggah ke Firebase (antrian offline).
  Future<({List<Detection> detections, Failure? failure})>
  getPendingDetections();

  Future<({Detection? detection, Failure? failure})> saveDetection(
    Detection detection, {
    required String userEmail,
    required String userName,
  });

  Future<({int synced, Failure? failure})> markSynced({
    required String code,
    required DateTime syncedAt,
  });
}