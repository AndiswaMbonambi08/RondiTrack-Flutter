import 'package:flutter/services.dart' show appFlavor;

enum Flavor { dev, staging, prod }

class ConfigError implements Exception {
  ConfigError(this.message);

  final String message;

  @override
  String toString() => 'ConfigError: $message';
}

class AppConfig {
  const AppConfig({required this.flavor, required this.apiBaseUrl});

  factory AppConfig.fromEnvironment() => AppConfig.resolve(
    flavor: const String.fromEnvironment('FLAVOR'),
    apiBaseUrl: const String.fromEnvironment('API_BASE_URL'),
    nativeFlavor: appFlavor,
  );

  /// Pure and testable: validates the dart-define values against the native
  /// flavour the binary was built with.
  factory AppConfig.resolve({
    required String flavor,
    required String apiBaseUrl,
    required String? nativeFlavor,
  }) {
    if (flavor.isEmpty || apiBaseUrl.isEmpty) {
      throw ConfigError(
        'No config. Run with --dart-define-from-file=config/<flavor>.json',
      );
    }
    final parsed = Flavor.values.where((f) => f.name == flavor).firstOrNull;
    if (parsed == null) {
      throw ConfigError('Unknown flavor "$flavor" in config.');
    }
    final uri = Uri.tryParse(apiBaseUrl);
    if (uri == null || !uri.hasScheme) {
      throw ConfigError('API_BASE_URL is not an absolute URL.');
    }
    if (nativeFlavor != parsed.name) {
      throw ConfigError(
        'Native flavor "$nativeFlavor" does not match config "$flavor". '
        'Use the config file that matches --flavor.',
      );
    }
    return AppConfig(flavor: parsed, apiBaseUrl: apiBaseUrl);
  }

  final Flavor flavor;
  final String apiBaseUrl;
}