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
  final String? plantId;
  final String? plantName;
  final String? plantLocation;

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
    this.plantId,
    this.plantName,
    this.plantLocation,
  });

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

  Map<String, dynamic> toApiJson() {
    return {
      'id_riwayat': id,
      'id_pengguna': userId,
      'id_tanaman': plantId,
      'nama_tanaman': plantName,
      'lokasi': plantLocation,
      'nama_penyakit': diseaseName,
      'confidence_score': confidence,
      'tanggal_pemeriksaan': scannedAt.toIso8601String(),
      'catatan': notes,
      'foto_daun': localImagePath,
    };
  }

  ScanRecordModel copyWith({
    String? cloudImageUrl,
    String? notes,
    bool? isSynced,
    String? plantId,
    String? plantName,
    String? plantLocation,
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
      plantId: plantId ?? this.plantId,
      plantName: plantName ?? this.plantName,
      plantLocation: plantLocation ?? this.plantLocation,
    );
  }
}
