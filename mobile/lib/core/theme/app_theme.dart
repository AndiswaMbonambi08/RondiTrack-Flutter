import 'package:flutter/material.dart';
import 'package:ronditrack/core/theme/status_colors.dart';
import 'package:ronditrack/core/theme/tokens.dart';

/// RondiTrack's one seed colour: a deep green.
const seedColour = Color(0xFF1B6B4A);

/// Material 3 from the seed. The page colours come from the tokens, so the
/// measured contrast in the README is the contrast on screen.
ThemeData buildTheme(Brightness brightness) {
  final page = brightness == Brightness.dark ? pageDark : pageLight;
  final scheme =
      ColorScheme.fromSeed(
        seedColor: seedColour,
        brightness: brightness,
      ).copyWith(
        surface: Color(page.background),
        onSurface: Color(page.foreground),
      );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    extensions: [StatusColors.forBrightness(brightness)],
  );
}
