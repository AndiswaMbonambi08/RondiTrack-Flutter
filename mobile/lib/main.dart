import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/app/app.dart';
import 'package:ronditrack/app/config.dart';
import 'package:ronditrack/app/config_provider.dart';
import 'package:ronditrack/core/network/dio_provider.dart';

void main() {
  final config = AppConfig.fromEnvironment();
  runApp(
    ProviderScope(
      overrides: [
        apiBaseUrlProvider.overrideWithValue(config.apiBaseUrl),
        appConfigProvider.overrideWithValue(config),
      ],
      child: RondiTrackApp(config: config),
    ),
  );
}
