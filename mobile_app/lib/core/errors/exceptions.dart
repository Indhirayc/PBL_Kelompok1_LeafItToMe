class NetworkException implements Exception {
  const NetworkException(this.message);

  final String message;
}

class ServerException implements Exception {
  const ServerException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;
}

class ConfigurationException implements Exception {
  const ConfigurationException(this.message);

  final String message;
}
