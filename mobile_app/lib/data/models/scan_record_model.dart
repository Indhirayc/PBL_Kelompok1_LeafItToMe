import 'package:cloud_firestore/cloud_firestore.dart';

class ScanRecordModel {
  final String id;
  final String userId;
  final String? plantId;
  final String diseaseName;
  final double confidence;
  final String localImagePath;
  final String? cloudImageUrl;
  final String? notes;
  final DateTime scannedAt;
  final bool isSynced;

  ScanRecordModel({
    required this.id,
    required this.userId,
    this.plantId,
    required this.diseaseName,
    required this.confidence,
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
      'disease_label': diseaseName,
      'confidence': confidence,
      'local_image_path': localImagePath,
      'cloud_image_url': cloudImageUrl,
      'notes': notes,
      'scanned_at': scannedAt.toUtc().toIso8601String(),
      'sync_status': isSynced ? 'synced' : 'pending',
    };
  }

  factory ScanRecordModel.fromSqliteMap(Map<String, dynamic> map) {
    return ScanRecordModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      plantId: map['plant_id'] as String?,
      diseaseName: (map['disease_label'] ?? map['disease_name']) as String,
      confidence: (map['confidence'] as num).toDouble(),
      localImagePath: map['local_image_path'] as String,
      cloudImageUrl: map['cloud_image_url'] as String?,
      notes: map['notes'] as String?,
      scannedAt: DateTime.parse(map['scanned_at'] as String),
      isSynced: map['sync_status'] == null
          ? (map['is_synced'] as int? ?? 0) == 1
          : map['sync_status'] == 'synced',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'user_id': userId,
      'disease_name': diseaseName,
      'confidence': confidence,
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
      diseaseName: diseaseName,
      confidence: confidence,
      localImagePath: localImagePath,
      cloudImageUrl: cloudImageUrl ?? this.cloudImageUrl,
      notes: notes ?? this.notes,
      scannedAt: scannedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
