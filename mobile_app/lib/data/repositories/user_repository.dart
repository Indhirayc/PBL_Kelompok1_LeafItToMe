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
}
