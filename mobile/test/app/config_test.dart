import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/app/config.dart';

void main() {
  group('AppConfig.resolve', () {
    test('refuses to start without a config', () {
      expect(
        () =>
            AppConfig.resolve(flavor: '', apiBaseUrl: '', nativeFlavor: 'dev'),
        throwsA(isA<ConfigError>()),
      );
    });

    test('refuses a build whose native flavour does not match its config', () {
      expect(
        () => AppConfig.resolve(
          flavor: 'dev',
          apiBaseUrl: 'http://10.0.2.2:5051',
          nativeFlavor: 'prod',
        ),
        throwsA(isA<ConfigError>()),
      );
    });

    test('accepts a matching flavour and config', () {
      final config = AppConfig.resolve(
        flavor: 'staging',
        apiBaseUrl: 'https://staging.ronditrack.example',
        nativeFlavor: 'staging',
      );
      expect(config.flavor, Flavor.staging);
    });
  });
}
