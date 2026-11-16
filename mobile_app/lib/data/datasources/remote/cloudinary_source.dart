import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class CloudinarySource {
  final Dio _dio = Dio();

  // Ganti dengan Cloud Name Anda atau ambil dari environment config
  static const String _cloudName = 'mgjlgtpf';

  // Ganti dengan Unsigned Upload Preset yang sudah dibuat di dashboard
  static const String _uploadPreset = 'leafittome_unsigned';

  /// Mengunggah file gambar lokal ke Cloudinary secara unsigned.
  /// Mengembalikan map berisi [secure_url] dan [public_id].
  Future<Map<String, String>> uploadScanImage({
    required String userId,
    required String localPath,
  }) async {
    try {
      final url = 'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(localPath),
        'upload_preset': _uploadPreset,
        'folder': 'leafittome/scans/$userId',
      });

      final response = await _dio.post(
        url,
        data: formData,
        onSendProgress: (sent, total) {
          if (total != -1) {
            final progress = (sent / total * 100).toStringAsFixed(0);
            debugPrint('Cloudinary Upload Progress: $progress%');
          }
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return {
          'secure_url': data['secure_url'] as String,
          'public_id': data['public_id'] as String,
        };
      } else {
        throw Exception(
          'Gagal mengunggah gambar ke Cloudinary: status ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Cloudinary Error: $e');
      rethrow;
    }
  }
}
