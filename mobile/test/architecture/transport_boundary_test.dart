import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// True for an import that reaches the transport: Dio, Retrofit, JSON
/// annotations, core/network, any data/ folder or a generated client.
bool importsTransport(String line) {
  final t = line.trimLeft();
  if (!t.startsWith('import')) return false;
  return t.contains('package:dio/') ||
      t.contains('package:retrofit/') ||
      t.contains('package:json_annotation/') ||
      t.contains('/core/network/') ||
      t.contains('/data/') ||
      t.contains('/generated/');
}

List<File> guardedFiles() {
  final layers = RegExp(r'[/\\](presentation|domain)[/\\]');
  return [
    for (final entity in Directory('lib/features').listSync(recursive: true))
      if (entity is File &&
          entity.path.endsWith('.dart') &&
          layers.hasMatch(entity.path))
        entity,
    File('lib/core/widgets.dart'),
    File('lib/core/view_state.dart'),
  ].where((f) => f.existsSync()).toList();
}

void main() {
  test('the guard finds the files it is meant to guard', () {
    expect(guardedFiles().length, greaterThan(10));
  });

  test(
    'no presentation or domain file imports Dio or the generated client',
    () {
      final offenders = <String>[
        for (final file in guardedFiles())
          for (final line in file.readAsLinesSync())
            if (importsTransport(line)) '${file.path}: ${line.trim()}',
      ];
      expect(offenders, isEmpty, reason: offenders.join('\n'));
    },
  );

  test('the rule catches what it should and leaves the rest', () {
    expect(importsTransport("import 'package:dio/dio.dart';"), isTrue);
    expect(
      importsTransport("import 'package:ronditrack/core/network/x.dart';"),
      isTrue,
    );
    expect(
      importsTransport("import 'package:ronditrack/features/a/data/b.dart';"),
      isTrue,
    );
    expect(
      importsTransport("import 'package:flutter/material.dart';"),
      isFalse,
    );
    expect(importsTransport('// import dio'), isFalse);
  });
}
