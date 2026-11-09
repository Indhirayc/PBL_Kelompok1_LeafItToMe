import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/errors/exceptions.dart';
import 'package:mobile_app/core/errors/failures.dart';
import 'package:mobile_app/core/utils/error_message.dart';

void main() {
  group('friendlyErrorMessage', () {
    test('returns the configuration message for an unconfigured backend', () {
      expect(
        friendlyErrorMessage(
          const ConfigurationFailure('internal configuration detail'),
        ),
        'Backend LeafItToMe belum dikonfigurasi.',
      );
    });

    test('maps a network failure to a helpful message', () {
      expect(
        friendlyErrorMessage(const NetworkFailure('connection refused')),
        'Tidak dapat terhubung ke server. Periksa koneksi internet.',
      );
    });

    test('maps a Dio exception cause without unsafe casts', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/plants'),
        error: const NetworkException('connection failed'),
      );

      expect(
        friendlyErrorMessage(error),
        'Tidak dapat terhubung ke server. Periksa koneksi internet.',
      );
    });
  });
}
