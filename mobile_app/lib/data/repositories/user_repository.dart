import 'dart:async';
import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../datasources/local/app_database.dart';
import '../datasources/remote/api_service.dart';
import '../models/user_model.dart';

class UserRepository {
  static final UserRepository instance = UserRepository._internal();
  factory UserRepository() => instance;
  UserRepository._internal();

  final ApiService _apiService = ApiService(); // Panggil Api Service Dio
  final _controller = StreamController<UserModel?>.broadcast();
  UserModel? _cachedUser;

  Stream<UserModel?> get authStateChanges async* {
    _cachedUser ??= await getCurrentUserProfile();
    yield _cachedUser;
    yield* _controller.stream;
  }

  String? get currentUserId => _cachedUser?.uid;

  Future<UserModel?> getCurrentUserProfile() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'app_meta',
      where: "key = 'current_user'",
      limit: 1,
    );
    if (rows.isEmpty) return null;
    try {
      final json =
          jsonDecode(rows.first['value'] as String) as Map<String, dynamic>;
      _cachedUser = UserModel.fromJson(json);
      return _cachedUser;
    } catch (_) {
      return null;
    }
  }

  /// 1. IMPLEMENTASI LOGIN KE BACKEND MYSQL (DOCKER)
  Future<void> login(String email, String password) async {
    try {
      // Kirim data ke backend via Dio
      final response = await _apiService.login(email, password);

      if (response['status'] == 'success') {
        final userData = response['user'];
        final user = UserModel(
          uid: userData['id_pengguna'] ?? 'user-${email.split('@').first}',
          namaLengkap: userData['nama_lengkap'] ?? email.split('@').first,
          email: userData['email'] ?? email,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _saveUser(user);
      } else {
        // PERBAIKAN 1: Langsung lempar message dari server (misal: "Email belum terdaftar")
        throw Exception(response['message'] ?? 'Login gagal di server');
      }
    } catch (e) {
      // PERBAIKAN 2: Jika error dari server (yang sudah dilempar di atas), teruskan apa adanya.
      // Jika error karena benar-benar mati lampu/tidak ada internet (DioException), baru tampilkan pesan koneksi.
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Gagal terhubung ke server backend: $e');
    }
  }

  /// 2. IMPLEMENTASI REGISTER KE BACKEND MYSQL (DOCKER)
  Future<UserModel> register(
    String email,
    String password,
    String namaLengkap,
  ) async {
    try {
      // Kirim data registrasi ke backend via Dio
      final response = await _apiService.register(namaLengkap, email, password);

      if (response['status'] == 'success') {
        final user = UserModel(
          uid: 'user-${DateTime.now().millisecondsSinceEpoch}',
          namaLengkap: namaLengkap,
          email: email,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _saveUser(user);
        return user;
      } else {
        throw Exception(response['message'] ?? 'Registrasi gagal di server');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server backend: $e');
    }
  }

  Future<void> logout() async {
    final db = await AppDatabase.instance.database;
    await db.delete('app_meta', where: "key = 'current_user'");
    _cachedUser = null;
    _controller.add(null);
  }

  Future<void> updateUserProfile({
    String? namaLengkap,
    String? noTelepon,
  }) async {
    final current =
        await getCurrentUserProfile() ??
        UserModel(
          uid: 'user-local',
          namaLengkap: '',
          email: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
    final updated = UserModel(
      uid: current.uid,
      namaLengkap: namaLengkap ?? current.namaLengkap,
      email: current.email,
      noTelepon: noTelepon ?? current.noTelepon,
      fotoProfil: current.fotoProfil,
      role: current.role,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
    );
    await _saveUser(updated);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    // Implementasi opsional pemanggilan API reset password ke backend jika diperlukan
  }

  Future<void> _saveUser(UserModel user) async {
    final db = await AppDatabase.instance.database;
    await db.insert('app_meta', {
      'key': 'current_user',
      'value': jsonEncode(user.toJson()),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    _cachedUser = user;
    _controller.add(user);
  }
}
