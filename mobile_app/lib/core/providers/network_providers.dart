import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_config.dart';
import '../network/api_client.dart';
import '../network/network_info.dart';

final Provider<ApiConfig> apiConfigProvider = Provider<ApiConfig>(
  (ref) => ApiConfig.defaultConfig,
);

final Provider<Connectivity> connectivityProvider = Provider<Connectivity>(
  (ref) => Connectivity(),
);

final Provider<NetworkInfo> networkInfoProvider = Provider<NetworkInfo>(
  (ref) => NetworkInfoImpl(ref.watch(connectivityProvider)),
);

final Provider<Dio> dioProvider = Provider<Dio>((ref) {
  final dio = createApiClient(config: ref.watch(apiConfigProvider));
  ref.onDispose(dio.close);
  return dio;
});
