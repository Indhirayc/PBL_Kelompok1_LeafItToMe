import 'package:dio/dio.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        // ATUR BASE URL DI SINI SESUAI KEBUTUHAN:
        // - Jika pakai Emulator Android: 'http://10.0.2.2:8080/'
        // - Jika pakai HP Fisik via USB: 'http://<IP_WIFI_KOMPUTER>:8080/'
        baseUrl: 'http://192.168.18.43:8080/',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  // 1. Endpoint Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        'login.php',
        data: {'email': email, 'password': password},
      );
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  // 2. Endpoint Register
  Future<Map<String, dynamic>> register(
    String nama,
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        'register.php',
        data: {'nama_lengkap': nama, 'email': email, 'password': password},
      );
      return response.data;
    } catch (e) {
      return {'status': 'error', 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  // 3. Endpoint Simpan/Sinkronisasi Scan
  Future<bool> saveScan(Map<String, dynamic> scanData) async {
    try {
      final response = await _dio.post('save_scan.php', data: scanData);
      return response.data['status'] == 'success';
    } catch (e) {
      return false;
    }
  }

  // 4. Endpoint Ambil Riwayat (Restore dari Cloud)
  Future<List<dynamic>> getHistory(String userId) async {
    try {
      final response = await _dio.get(
        'get_history.php',
        queryParameters: {'user_id': userId},
      );
      if (response.data['status'] == 'success') {
        return response.data['data'];
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
