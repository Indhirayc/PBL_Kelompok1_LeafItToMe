import 'package:cloud_firestore/cloud_firestore.dart';

class ScanRecordModel {
  final String id;
  final String userId;
  final String plantId;
  final String? plantName;
  final String? plantLocation;
  final String diseaseName;
  final String? latinName;
  final double confidence;
  final bool isHealthy;
  final String localImagePath;
  final String? cloudImageUrl;
  final String? notes;
  final DateTime scannedAt;
  final bool isSynced;

  ScanRecordModel({
    required this.id,
    required this.userId,
    required this.plantId,
    this.plantName,
    this.plantLocation,
    required this.diseaseName,
    this.latinName,
    required this.confidence,
    this.isHealthy = false,
    required this.localImagePath,
    this.cloudImageUrl,
    this.notes,
    required this.scannedAt,
    this.isSynced = false,
  });

  Map<String, dynamic> toSqliteMap() {
    return {
      'id': id,
      'user_id': userId,
      'plant_id': plantId,
      'plant_name': plantName,
      'plant_location': plantLocation,
      'disease_name': diseaseName,
      'latin_name': latinName,
      'confidence': confidence,
      'is_healthy': isHealthy ? 1 : 0,
      'local_image_path': localImagePath,
      'cloud_image_url': cloudImageUrl,
      'notes': notes,
      'scanned_at': scannedAt.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory ScanRecordModel.fromSqliteMap(Map<String, dynamic> map) {
    return ScanRecordModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      plantId: (map['plant_id'] as String?) ?? '',
      plantName: map['plant_name'] as String?,
      plantLocation: map['plant_location'] as String?,
      diseaseName: map['disease_name'] as String,
      latinName: map['latin_name'] as String?,
      confidence: (map['confidence'] as num).toDouble(),
      isHealthy: (map['is_healthy'] as int? ?? 0) == 1,
      localImagePath: map['local_image_path'] as String,
      cloudImageUrl: map['cloud_image_url'] as String?,
      notes: map['notes'] as String?,
      scannedAt: DateTime.parse(map['scanned_at'] as String),
      isSynced: (map['is_synced'] as int) == 1,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'user_id': userId,
      'plant_id': plantId,
      'plant_name': plantName,
      'plant_location': plantLocation,
      'disease_name': diseaseName,
      'latin_name': latinName,
      'confidence': confidence,
      'is_healthy': isHealthy,
      'cloud_image_url': cloudImageUrl,
      'notes': notes,
      'scanned_at': Timestamp.fromDate(scannedAt),
    };
  }

  ScanRecordModel copyWith({
    String? cloudImageUrl,
    String? notes,
    bool? isSynced,
  }) {
    return ScanRecordModel(
      id: id,
      userId: userId,
      plantId: plantId,
      plantName: plantName,
      plantLocation: plantLocation,
      diseaseName: diseaseName,
      latinName: latinName,
      confidence: confidence,
      isHealthy: isHealthy,
      localImagePath: localImagePath,
      cloudImageUrl: cloudImageUrl ?? this.cloudImageUrl,
      notes: notes ?? this.notes,
      scannedAt: scannedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
