import 'package:dio/dio.dart';

import '../errors/exceptions.dart';
import '../errors/failures.dart';

String friendlyErrorMessage(Object error) {
  if (error is DioException) {
    final cause = error.error;
    if (cause is Exception) {
      return friendlyErrorMessage(cause);
    }
  }

  if (error is ConfigurationException || error is ConfigurationFailure) {
    return 'Backend LeafItToMe belum dikonfigurasi.';
  }

  if (error is ServerException) {
    return _serverStatusMessage(error.statusCode);
  }

  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Koneksi terlalu lambat. Silakan coba lagi.';
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return 'Server membutuhkan waktu terlalu lama untuk merespons.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Periksa koneksi internet.';
      case DioExceptionType.badResponse:
        return _serverStatusMessage(error.response?.statusCode);
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  if (error is NetworkException || error is NetworkFailure) {
    return 'Tidak dapat terhubung ke server. Periksa koneksi internet.';
  }

  if (error is ServerFailure) {
    return 'Server sedang mengalami gangguan.';
  }

  return 'Terjadi kesalahan. Silakan coba lagi.';
}

String _serverStatusMessage(int? statusCode) {
  return switch (statusCode) {
    400 => 'Data yang dikirim tidak valid.',
    401 => 'Sesi telah berakhir. Silakan masuk kembali.',
    403 => 'Kamu tidak memiliki izin untuk mengakses data ini.',
    404 => 'Data tidak ditemukan.',
    409 => 'Data sudah tersedia atau mengalami konflik.',
    500 => 'Server sedang mengalami gangguan.',
    _ => 'Terjadi kesalahan. Silakan coba lagi.',
  };
}
