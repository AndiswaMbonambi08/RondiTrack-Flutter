import 'dart:io';

/// Usage: dart run tool/check_coverage.dart 70
/// Fails (exit 1) if line coverage is below the floor.
void main(List<String> args) {
  final floor = double.parse(args.isEmpty ? '0' : args.first);
  final file = File('coverage/lcov.info');
  if (!file.existsSync()) {
    stderr.writeln('coverage/lcov.info not found. Run flutter test --coverage');
    exit(2);
  }

  // Generated code only. Never exclude hand-written files.
  final excluded = <RegExp>[
    RegExp(r'\.g\.dart$'),
    RegExp(r'\.freezed\.dart$'),
    RegExp(r'\.gen\.dart$'),
    RegExp(r'lib[\\/]l10n[\\/]app_localizations.*\.dart$'),
  ];

  var found = 0;
  var hit = 0;
  var skip = false;
  for (final line in file.readAsLinesSync()) {
    if (line.startsWith('SF:')) {
      final path = line.substring(3);
      skip = excluded.any((r) => r.hasMatch(path));
    } else if (!skip && line.startsWith('DA:')) {
      final parts = line.substring(3).split(',');
      found++;
      if (int.parse(parts[1]) > 0) hit++;
    }
  }

  final pct = found == 0 ? 0.0 : hit * 100 / found;
  stdout.writeln(
    'Line coverage: ${pct.toStringAsFixed(2)}% '
    '($hit/$found), floor: $floor%',
  );
  if (pct < floor) {
    stderr.writeln('Coverage dropped below the floor.');
    exit(1);
  }
}
