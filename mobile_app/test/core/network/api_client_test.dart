import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/errors/exceptions.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/core/network/api_config.dart';

void main() {
  test(
    'blocks requests and preserves configuration errors without a base URL',
    () async {
      final dio = createApiClient(config: const ApiConfig());
      addTearDown(dio.close);

      await expectLater(
        dio.get<dynamic>('/plants'),
        throwsA(
          isA<DioException>().having(
            (error) => error.error,
            'cause',
            isA<ConfigurationException>(),
          ),
        ),
      );
    },
  );
}
