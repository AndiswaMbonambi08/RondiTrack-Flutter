import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/theme/status_colors.dart';
import 'package:ronditrack/core/theme/tokens.dart';

void main() {
  test('the Next token is measured, light and dark', () {
    final spec = tokenSpec('next');
    expect(
      contrastRatio(spec.light.foreground, spec.light.background),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      contrastRatio(spec.dark.foreground, spec.dark.background),
      greaterThanOrEqualTo(4.5),
    );
  });

  test('the Next token is its own colour, not a reused pair', () {
    final spec = tokenSpec('next');
    for (final other in tokenSpecs.where((s) => s.name != 'next')) {
      expect(other.light.foreground, isNot(spec.light.foreground));
      expect(other.dark.background, isNot(spec.dark.background));
    }
  });

  test('StatusColors.next reads the token in light and dark', () {
    final spec = tokenSpec('next');
    final light = StatusColors.forBrightness(Brightness.light).next;
    final dark = StatusColors.forBrightness(Brightness.dark).next;
    expect(light.foreground, Color(spec.light.foreground));
    expect(light.background, Color(spec.light.background));
    expect(dark.foreground, Color(spec.dark.foreground));
    expect(dark.background, Color(spec.dark.background));
  });
}
