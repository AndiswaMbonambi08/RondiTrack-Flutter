import 'dart:io';

import 'package:ronditrack/core/theme/tokens.dart';

String _hex(int argb) =>
    '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

String _pair(int foreground, int background) =>
    '${_hex(foreground)} on ${_hex(background)}: '
    '${contrastRatio(foreground, background).toStringAsFixed(2)}:1';

/// Prints the README contrast table: dart run tool/contrast_table.dart
void main() {
  stdout
    ..writeln(
      '| Token | Theme | Text on its chip (needs 4.5:1) '
      '| Border on the page (needs 3:1) |',
    )
    ..writeln('| --- | --- | --- | --- |');
  for (final (name, light, dark) in [
    ('body text', pageLight, pageDark),
    for (final s in tokenSpecs) (s.name, s.light, s.dark),
  ]) {
    for (final (label, tone, page) in [
      ('light', light, pageLight),
      ('dark', dark, pageDark),
    ]) {
      final border = name == 'body text'
          ? 'n/a'
          : _pair(tone.foreground, page.background);
      stdout.writeln(
        '| $name | $label | ${_pair(tone.foreground, tone.background)} '
        '| $border |',
      );
    }
  }
}
