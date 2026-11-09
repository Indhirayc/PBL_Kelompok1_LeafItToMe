import 'package:firebase_auth/firebase_auth.dart' as fb;

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mobile_app/data/models/user_model.dart';

class FirebaseAuthSource {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream status login user
  Stream<fb.User?> get authStateChanges => _auth.authStateChanges();

  // User saat ini
  fb.User? get currentUser => _auth.currentUser;

  // Login dengan Email & Password
  Future<fb.UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Register dengan Email & Password + Buat Dokumen users/{uid}
  Future<UserModel> register({
    required String email,
    required String password,
    required String namaLengkap,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;
    final now = DateTime.now();

    final userModel = UserModel(
      uid: uid,
      namaLengkap: namaLengkap,
      email: email,
      createdAt: now,
      updatedAt: now,
    );

    // Simpan ke koleksi users/{uid} di Firestore
    await _firestore.collection('users').doc(uid).set(userModel.toFirestore());

    return userModel;
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Ambil profil user dari Firestore
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }
}
