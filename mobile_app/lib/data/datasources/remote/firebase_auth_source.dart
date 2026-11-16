import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app/data/models/user_model.dart';

class FirebaseAuthSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseAuthSource({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // Stream status login user
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // User saat ini
  User? get currentUser => _auth.currentUser;

  // Sign in / Login dengan Email & Password
  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await signIn(email, password);
  }

  // Sign up / Register dengan Email & Password + Buat Dokumen users/{uid}
  Future<UserCredential> signUp(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserModel> register({
    required String email,
    required String password,
    required String namaLengkap,
  }) async {
    final credential = await signUp(email, password);

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

  // Sign out / Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> logout() async {
    await signOut();
  }

  // Ambil profil user dari Firestore
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }
}
