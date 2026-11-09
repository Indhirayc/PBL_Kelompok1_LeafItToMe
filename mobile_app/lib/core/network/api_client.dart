import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../errors/exceptions.dart';
import 'api_config.dart';

const String _notConfiguredMessage = 'Backend LeafItToMe belum dikonfigurasi.';

Dio createApiClient({ApiConfig config = ApiConfig.defaultConfig}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        if (!config.isConfigured) {
          handler.reject(
            DioException(
              requestOptions: options,
              error: const ConfigurationException(_notConfiguredMessage),
            ),
          );
          return;
        }

        if (kDebugMode) {
          debugPrint('HTTP ${options.method} ${options.uri.path}');
        }
        handler.next(options);
      },
      onError: (error, handler) {
        final cause = error.error;
        if (cause is Exception) {
          handler.next(error);
          return;
        }

        final mappedError = mapDioException(error);
        handler.reject(
          DioException(
            requestOptions: error.requestOptions,
            response: error.response,
            type: error.type,
            error: mappedError,
            message: error.message,
          ),
        );
      },
    ),
  );

  return dio;
}

Exception mapDioException(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
      return const NetworkException('Connection timeout.');
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return const NetworkException('Request timed out.');
    case DioExceptionType.connectionError:
      return const NetworkException('Connection error.');
    case DioExceptionType.badResponse:
      return ServerException(
        'Server returned an error response.',
        statusCode: error.response?.statusCode,
      );
    case DioExceptionType.cancel:
    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
      return const NetworkException('Network request failed.');
  }
}
