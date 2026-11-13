import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/scan_record_model.dart';

class FirestoreScanSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Menyimpan hasil scan ke subkoleksi users/{uid}/scans/{scanId}
  Future<void> saveScanRecord(ScanRecordModel record) async {
    await _firestore
        .collection('users')
        .doc(record.userId)
        .collection('scans')
        .doc(record.id)
        .set(record.toFirestore(), SetOptions(merge: true));
  }

  /// Mengambil riwayat scan user dari Cloud Firestore
  Future<List<ScanRecordModel>> getUserScans(String userId) async {
    final query = await _firestore
        .collection('users')
        .doc(userId)
        .collection('scans')
        .orderBy('scanned_at', descending: true)
        .get();

    return query.docs.map((doc) {
      final data = doc.data();
      return ScanRecordModel(
        id: doc.id,
        userId: data['user_id'] ?? userId,
        plantId: data['plant_id'] ?? '',
        plantName: data['plant_name'],
        plantLocation: data['plant_location'],
        diseaseName: data['disease_name'] ?? '',
        latinName: data['latin_name'],
        confidence: (data['confidence'] as num?)?.toDouble() ?? 0.0,
        isHealthy: data['is_healthy'] ?? false,
        localImagePath: '',
        cloudImageUrl: data['cloud_image_url'],
        notes: data['notes'],
        scannedAt: (data['scanned_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
        isSynced: true,
      );
    }).toList();
  }
}

