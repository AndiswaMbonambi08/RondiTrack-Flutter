import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('no colour is typed anywhere outside lib/core/theme', () {
    final offenders = <String>[];
    final pattern = RegExp(r'\bColors\.|\bColor\(|\bColor\.from');
    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File) continue;
      final path = file.path.replaceAll(r'\', '/');
      if (!path.endsWith('.dart') ||
          path.endsWith('.g.dart') ||
          path.endsWith('.freezed.dart') ||
          path.contains('/core/theme/')) {
        continue;
      }
      if (pattern.hasMatch(file.readAsStringSync())) offenders.add(path);
    }
    expect(offenders, isEmpty, reason: 'Ask the theme instead: $offenders');
  });
}
