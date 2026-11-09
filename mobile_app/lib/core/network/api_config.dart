final class ApiConfig {
  const ApiConfig({
    this.baseUrl = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: '',
    ),
  });

  static const defaultConfig = ApiConfig();

  final String baseUrl;

  bool get isConfigured => baseUrl.trim().isNotEmpty;
}
