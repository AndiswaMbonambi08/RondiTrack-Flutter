import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/theme/app_theme.dart';
import 'package:ronditrack/core/theme/status_colors.dart';
import 'package:ronditrack/core/theme/tokens.dart';

void main() {
  test('both themes carry the status colours, each with its own values', () {
    final light = buildTheme(Brightness.light).extension<StatusColors>()!;
    final dark = buildTheme(Brightness.dark).extension<StatusColors>()!;
    final pairs = <(StatusStyle, StatusStyle)>[
      (light.pending, dark.pending),
      (light.paid, dark.paid),
      (light.confirmed, dark.confirmed),
      (light.open, dark.open),
      (light.closed, dark.closed),
      (light.paidOut, dark.paidOut),
      (light.unknown, dark.unknown),
      (light.arrears, dark.arrears),
    ];
    for (final (l, d) in pairs) {
      expect(l.foreground, isNot(d.foreground));
      expect(l.background, isNot(d.background));
    }
  });

  test('page colours come from the tokens', () {
    expect(
      buildTheme(Brightness.dark).colorScheme.surface,
      Color(pageDark.background),
    );
    expect(
      buildTheme(Brightness.light).colorScheme.onSurface,
      Color(pageLight.foreground),
    );
  });
}
