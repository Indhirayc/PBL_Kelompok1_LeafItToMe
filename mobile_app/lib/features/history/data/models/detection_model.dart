import '../../domain/entities/detection.dart';

/// Representasi baris database untuk riwayat scan + pemetaannya.
///
/// Pemetaan (map <-> entitas) sengaja hanya hidup di layer data. Model
/// merupakan [Detection] sehingga dapat langsung dikembalikan sebagai entitas.
class DetectionModel extends Detection {
  const DetectionModel({
    super.code,
    required super.plantCode,
    required super.plantName,
    super.plantLocation,
    super.diseaseName,
    super.latinName,
    super.severity,
    super.severityColor,
    required super.accuracy,
    required super.isHealthy,
    super.note = '',
    required super.inspectedAt,
    super.isSynced = false,
    super.syncedAt,
    super.photoPath,
    super.photoSource,
  });

  /// Baris hasil query view `v_detection_details`.
  factory DetectionModel.fromViewMap(Map<String, Object?> map) {
    return DetectionModel(
      code: map['detection_code'] as String?,
      plantCode: map['plant_code'] as String? ?? '',
      plantName: map['plant_name'] as String? ?? '',
      plantLocation: map['plant_location'] as String?,
      diseaseName: map['disease_name'] as String?,
      latinName: map['latin_name'] as String?,
      severity: map['severity'] as String?,
      severityColor: map['severity_color'] as String?,
      accuracy: (map['accuracy'] as num?)?.toInt() ?? 0,
      isHealthy: _asFlag(map['is_healthy']),
      note: map['note'] as String? ?? '',
      inspectedAt:
          DateTime.tryParse(map['inspected_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      isSynced: _asFlag(map['is_synced']),
      syncedAt: DateTime.tryParse(map['synced_at'] as String? ?? ''),
      photoPath: map['photo_path'] as String?,
      photoSource: map['photo_source'] as String?,
    );
  }

  /// Menyalin entitas domain ke model data.
  factory DetectionModel.fromEntity(Detection detection) {
    return DetectionModel(
      code: detection.code,
      plantCode: detection.plantCode,
      plantName: detection.plantName,
      plantLocation: detection.plantLocation,
      diseaseName: detection.diseaseName,
      latinName: detection.latinName,
      severity: detection.severity,
      severityColor: detection.severityColor,
      accuracy: detection.accuracy,
      isHealthy: detection.isHealthy,
      note: detection.note,
      inspectedAt: detection.inspectedAt,
      isSynced: detection.isSynced,
      syncedAt: detection.syncedAt,
      photoPath: detection.photoPath,
      photoSource: detection.photoSource,
    );
  }

  Detection toEntity() => this;

  /// Baris untuk disisipkan ke tabel `detections` (foreign key sudah diresolusi).
  Map<String, Object?> toDetectionInsertMap({
    required int userId,
    required int plantId,
    int? imageId,
    int? diseaseId,
  }) {
    return <String, Object?>{
      'code': code,
      'user_id': userId,
      'plant_id': plantId,
      'image_id': imageId,
      'disease_id': isHealthy ? null : diseaseId,
      'is_healthy': isHealthy ? 1 : 0,
      'accuracy': accuracy,
      'note': note,
      'inspected_at': inspectedAt.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
      'synced_at': syncedAt?.toIso8601String(),
    };
  }

  static bool _asFlag(Object? value) => (value as num?)?.toInt() == 1;
}