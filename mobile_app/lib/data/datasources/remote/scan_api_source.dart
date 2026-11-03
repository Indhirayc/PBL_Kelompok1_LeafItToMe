import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../models/scan_record_model.dart';

abstract interface class ScanApiSource {
  Future<void> saveScan(ScanRecordModel scan);
  Future<String?> uploadScanImage(String scanId, String localPath);
  Future<void> deleteScan(String scanId);
}

class ScanApiSourceImpl implements ScanApiSource {
  ScanApiSourceImpl(this._dio, {this.apiConfig = ApiConfig.defaultConfig});

  final Dio _dio;
  final ApiConfig apiConfig;

  static const String _notConfiguredMessage =
      'Backend LeafItToMe belum dikonfigurasi.';

  Future<T> _request<T>(Future<T> Function() request) async {
    if (!apiConfig.isConfigured) {
      throw const ConfigurationException(_notConfiguredMessage);
    }

    try {
      return await request();
    } on DioException catch (error) {
      final cause = error.error;
      if (cause is Exception) {
        throw cause;
      }
      throw mapDioException(error);
    }
  }

  @override
  Future<void> saveScan(ScanRecordModel scan) {
    return _request(() async {
      await _dio.post<dynamic>('/scans', data: scan.toApiJson());
    });
  }

  @override
  Future<String?> uploadScanImage(String scanId, String localPath) {
    return _request(() async {
      final file = File(localPath);
      if (!await file.exists()) {
        return null;
      }

      final form = FormData();
      form.files.add(
        MapEntry(
          'image',
          await MultipartFile.fromFile(localPath, filename: '$scanId.jpg'),
        ),
      );

      final response = await _dio.post<dynamic>(
        '/scans/${Uri.encodeComponent(scanId)}/image',
        data: form,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final url = data['cloud_image_url'];
        if (url is String) {
          return url;
        }
      }

      return null;
    });
  }

  @override
  Future<void> deleteScan(String scanId) {
    return _request(() async {
      await _dio.delete<void>('/scans/${Uri.encodeComponent(scanId)}');
    });
  }
}
