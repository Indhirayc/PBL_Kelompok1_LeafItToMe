/// Entitas murni riwayat scan (deteksi).
///
/// Tanpa dependensi Flutter, SQLite, atau Firebase — logika bisnis dapat diuji
/// sendiri (Clean Architecture: domain). Dipetakan dari view `v_detection_details`.
class Detection {
  const Detection({
    this.code,
    required this.plantCode,
    required this.plantName,
    this.plantLocation,
    this.diseaseName,
    this.latinName,
    this.severity,
    this.severityColor,
    required this.accuracy,
    required this.isHealthy,
    this.note = '',
    required this.inspectedAt,
    this.isSynced = false,
    this.syncedAt,
    this.photoPath,
    this.photoSource,
  });

  /// Kode bisnis riwayat, mis. `H-001`.
  final String? code;
  final String plantCode;
  final String plantName;
  final String? plantLocation;
  final String? diseaseName;
  final String? latinName;
  final String? severity;
  final String? severityColor;
  final int accuracy;
  final bool isHealthy;
  final String note;
  final DateTime inspectedAt;
  final bool isSynced;
  final DateTime? syncedAt;

  /// PATH foto tanaman di storage perangkat (bukan isi gambarnya).
  final String? photoPath;
  final String? photoSource;
}