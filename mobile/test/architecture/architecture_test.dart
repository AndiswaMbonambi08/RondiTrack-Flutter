import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// One written-down exception: the file, why it exists, and the week it ends.
typedef RuleException = ({String file, String reason, int endsInWeek});

/// This week of the course. An exception whose week has passed fails the test.
const currentWeek = 10;

/// Files under lib/features that may type a colour. Empty on purpose.
const colourExceptions = <RuleException>[];

/// Screens that may import a data/ folder, Dio or Drift. Empty on purpose.
const screenImportExceptions = <RuleException>[];

final _typedColour = RegExp(r'\bColors\.|\bColor\(|\bColor\.from');
final _forbiddenImport = RegExp(
  r'''import\s+['"](package:ronditrack/features/[^'"]*/data/|\.\./data/|\.\./\.\./data/|package:dio/|package:drift/)''',
);

bool hasTypedColour(String source) => _typedColour.hasMatch(source);

bool hasForbiddenImport(String source) => _forbiddenImport.hasMatch(source);

String pathOf(File file) => file.path.replaceAll(r'\', '/');

List<File> dartFiles(String root) => Directory(root)
    .listSync(recursive: true)
    .whereType<File>()
    .where(
      (f) =>
          pathOf(f).endsWith('.dart') &&
          !pathOf(f).endsWith('.g.dart') &&
          !pathOf(f).endsWith('.freezed.dart'),
    )
    .toList();

void main() {
  test('every exception has a reason and an end week that has not passed', () {
    for (final e in [...colourExceptions, ...screenImportExceptions]) {
      expect(e.reason.trim(), isNotEmpty, reason: e.file);
      expect(
        e.endsInWeek,
        greaterThanOrEqualTo(currentWeek),
        reason: '${e.file} expired in week ${e.endsInWeek}',
      );
      expect(File(e.file).existsSync(), isTrue, reason: '${e.file} is gone');
    }
  });

  test('no file under lib/features types a colour', () {
    final allowed = colourExceptions.map((e) => e.file).toSet();
    final offenders = [
      for (final f in dartFiles('lib/features'))
        if (!allowed.contains(pathOf(f)) &&
            hasTypedColour(f.readAsStringSync()))
          pathOf(f),
    ];
    expect(offenders, isEmpty, reason: 'Ask the theme instead: $offenders');
  });

  test('no screen imports a data/ folder, Dio or Drift', () {
    final allowed = screenImportExceptions.map((e) => e.file).toSet();
    final screens = [
      ...dartFiles('lib/features')
          .where((f) => pathOf(f).contains('/presentation/')),
      ...dartFiles('lib/app'),
    ];
    final offenders = [
      for (final f in screens)
        if (!allowed.contains(pathOf(f)) &&
            hasForbiddenImport(f.readAsStringSync()))
          pathOf(f),
    ];
    expect(offenders, isEmpty, reason: 'Go through a provider: $offenders');
  });

  test('the rules catch what they are meant to catch', () {
    expect(hasTypedColour('color: Colors.red'), isTrue);
    expect(hasTypedColour('const Color(0xFF000000)'), isTrue);
    expect(hasTypedColour('context.statusColors.next'), isFalse);
    expect(hasForbiddenImport("import 'package:dio/dio.dart';"), isTrue);
    expect(hasForbiddenImport("import 'package:drift/drift.dart';"), isTrue);
    expect(
      hasForbiddenImport(
        "import 'package:ronditrack/features/stokvel/data/seed.dart';",
      ),
      isTrue,
    );
    expect(hasForbiddenImport("import '../data/seed.dart';"), isTrue);
    expect(
      hasForbiddenImport(
        "import 'package:ronditrack/features/stokvel/application/x.dart';",
      ),
      isFalse,
    );
  });
}
