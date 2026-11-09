import 'package:cloud_firestore/cloud_firestore.dart';

class ScanRecordModel {
  final String id;
  final String userId;
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
      'disease_name': diseaseName,
      'confidence': confidence,
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
      diseaseName: map['disease_name'] as String,
      confidence: (map['confidence'] as num).toDouble(),
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
