import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

void main() {
  test(
    'INTERNET is granted in main/, so a release build can reach the API',
    () {
      expect(
        _read('android/app/src/main/AndroidManifest.xml'),
        contains('android.permission.INTERNET'),
      );
    },
  );

  test('plain HTTP is not allowed in main/, staging or prod', () {
    final manifests = [
      'android/app/src/main/AndroidManifest.xml',
      for (final flavour in ['staging', 'prod'])
        'android/app/src/$flavour/AndroidManifest.xml',
    ];
    for (final path in manifests) {
      if (!File(path).existsSync()) continue;
      final xml = _read(path);
      expect(xml, isNot(contains('usesCleartextTraffic')), reason: path);
      expect(xml, isNot(contains('networkSecurityConfig')), reason: path);
    }
    for (final flavour in ['staging', 'prod']) {
      expect(
        Directory('android/app/src/$flavour/res/xml').existsSync(),
        isFalse,
        reason: '$flavour must have no network security config',
      );
    }
  });

  test('dev allows plain HTTP for exactly one host: the emulator alias', () {
    final xml = _read(
      'android/app/src/dev/res/xml/network_security_config.xml',
    );
    final hosts = RegExp(r'<domain[^>]*>([^<]+)</domain>')
        .allMatches(xml)
        .map((m) => m.group(1)!.trim())
        .toList();
    expect(hosts, ['10.0.2.2']);
    expect(xml, contains('<base-config cleartextTrafficPermitted="false"'));
    expect(
      _read('android/app/src/dev/AndroidManifest.xml'),
      contains('@xml/network_security_config'),
    );
  });

  test('staging and prod point at https', () {
    for (final flavour in ['staging', 'prod']) {
      final json =
          jsonDecode(_read('config/$flavour.json')) as Map<String, dynamic>;
      expect(json['API_BASE_URL'], startsWith('https://'), reason: flavour);
    }
  });
}
