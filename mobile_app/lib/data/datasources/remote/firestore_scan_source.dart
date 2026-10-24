import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/scan_record_model.dart';

class FirestoreScanSource {
  final FirebaseFirestore _firestore;

  FirestoreScanSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> saveScanRecord(ScanRecordModel record) async {
    await _firestore
        .collection('users')
        .doc(record.userId)
        .collection('scans')
        .doc(record.id)
        .set(record.toFirestore(), SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> fetchUserScans(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('scans')
        .orderBy('scanned_at', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
