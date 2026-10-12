import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/network/api_config.dart';

void main() {
  group('ApiConfig', () {
    test('treats an empty or whitespace-only base URL as unconfigured', () {
      expect(const ApiConfig().isConfigured, isFalse);
      expect(const ApiConfig(baseUrl: '  ').isConfigured, isFalse);
    });

    test('treats a non-empty base URL as configured', () {
      expect(
        const ApiConfig(baseUrl: 'https://api.leafittome.test').isConfigured,
        isTrue,
      );
    });
  });
}
