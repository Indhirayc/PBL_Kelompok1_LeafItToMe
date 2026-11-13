import '../datasources/remote/firebase_auth_source.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseAuthSource _authSource;

  UserRepository({FirebaseAuthSource? authSource})
    : _authSource = authSource ?? FirebaseAuthSource();

  Stream get authStateChanges => _authSource.authStateChanges;

  String? get currentUserId => _authSource.currentUser?.uid;

  Future<void> login(String email, String password) async {
    await _authSource.login(email: email, password: password);
  }

  Future<UserModel> register(
    String email,
    String password,
    String namaLengkap,
  ) async {
    return await _authSource.register(
      email: email,
      password: password,
      namaLengkap: namaLengkap,
    );
  }

  Future<void> logout() async {
    await _authSource.logout();
  }

  Future<UserModel?> getCurrentUserProfile() async {
    final uid = currentUserId;
    if (uid == null) return null;
    return await _authSource.getUserProfile(uid);
  }

  Future<void> updateUserProfile({
    String? namaLengkap,
    String? noTelepon,
  }) async {
    final uid = currentUserId;
    if (uid == null) {
      throw StateError('Tidak dapat memperbarui profil: user belum login.');
    }
    await _authSource.updateUserProfile(
      uid: uid,
      namaLengkap: namaLengkap,
      noTelepon: noTelepon,
    );
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _authSource.sendPasswordResetEmail(email);
  }
}
