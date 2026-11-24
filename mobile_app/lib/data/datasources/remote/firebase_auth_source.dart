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

    // Simpan nama ke profil Auth agar tampil konsisten di seluruh app
    await credential.user!.updateDisplayName(namaLengkap);

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

  // Perbarui profil user di Firestore (nama lengkap, nomor telepon, dan foto profil)
  Future<void> updateUserProfile({
    required String uid,
    String? namaLengkap,
    String? noTelepon,
    String? fotoProfil,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': Timestamp.fromDate(DateTime.now()),
    };
    if (namaLengkap != null) updates['nama_lengkap'] = namaLengkap;
    if (noTelepon != null) updates['no_telepon'] = noTelepon;
    if (fotoProfil != null) updates['foto_profil'] = fotoProfil;

    await _firestore
        .collection('users')
        .doc(uid)
        .set(updates, SetOptions(merge: true));

    // Samakan nama & foto di profil Auth agar header profil ikut berubah
    if (namaLengkap != null && namaLengkap.isNotEmpty) {
      await _auth.currentUser?.updateDisplayName(namaLengkap);
    }
    if (fotoProfil != null) {
      await _auth.currentUser?.updatePhotoURL(fotoProfil.isEmpty ? null : fotoProfil);
    }
  }

  // Kirim email reset password
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
