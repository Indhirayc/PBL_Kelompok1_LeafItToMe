import 'package:cloud_firestore/cloud_firestore.dart';

/// Sumber data master (diseases/guides/tools) dari Firestore.
/// Tulis/seed hanya dilakukan dari Firebase Console (rules: isAdmin),
/// aplikasi hanya membaca.
class MasterDataSource {
  final FirebaseFirestore _firestore;

  MasterDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Ambil semua dokumen dari satu koleksi master.
  /// Mengembalikan list map mentah (dokumen di-merge dengan field 'id').
  Future<List<Map<String, dynamic>>> fetchCollection(String collection) async {
    final snapshot = await _firestore.collection(collection).get();
    return snapshot.docs
        .map((doc) => <String, dynamic>{'id': doc.id, ...doc.data()})
        .toList(growable: false);
  }
}
