import 'dart:math' as math;

/// A foreground and a background as 0xAARRGGBB integers. Pure Dart on
/// purpose: tool/contrast_table.dart and the contrast test use it without
/// Flutter.
class Tone {
  const new({required this.foreground, required this.background});

  final int foreground;
  final int background;
}

class TokenSpec {
  const new({required this.name, required this.light, required this.dark});

  final String name;
  final Tone light;
  final Tone dark;
}

/// Body text on the page.
const pageLight = Tone(foreground: 0xFF191C1A, background: 0xFFFBFDF8);
const pageDark = Tone(foreground: 0xFFE0E4DF, background: 0xFF101411);

/// One entry per status token. The chip border uses the foreground colour.
const tokenSpecs = <TokenSpec>[
  TokenSpec(
    name: 'pending',
    light: Tone(foreground: 0xFF5F4100, background: 0xFFFFF0CC),
    dark: Tone(foreground: 0xFFFFD98A, background: 0xFF3D2C00),
  ),
  TokenSpec(
    name: 'paid',
    light: Tone(foreground: 0xFF0B3D66, background: 0xFFDCEEFF),
    dark: Tone(foreground: 0xFFA9D4FF, background: 0xFF0E2F4F),
  ),
  TokenSpec(
    name: 'confirmed',
    light: Tone(foreground: 0xFF0F4D2A, background: 0xFFD9F5E3),
    dark: Tone(foreground: 0xFFA6E8C0, background: 0xFF0D3320),
  ),
  TokenSpec(
    name: 'open',
    light: Tone(foreground: 0xFF00464A, background: 0xFFD4F3F5),
    dark: Tone(foreground: 0xFF9FE8EC, background: 0xFF00373A),
  ),
  TokenSpec(
    name: 'closed',
    light: Tone(foreground: 0xFF3A3F44, background: 0xFFE6E9EC),
    dark: Tone(foreground: 0xFFD3D8DD, background: 0xFF2B3035),
  ),
  TokenSpec(
    name: 'paidOut',
    light: Tone(foreground: 0xFF3F1D7A, background: 0xFFEBE3FF),
    dark: Tone(foreground: 0xFFD9C8FF, background: 0xFF2A1A55),
  ),
  TokenSpec(
    name: 'unknown',
    light: Tone(foreground: 0xFF4A4A4A, background: 0xFFEFEFEF),
    dark: Tone(foreground: 0xFFD0D0D0, background: 0xFF2E2E2E),
  ),
  TokenSpec(
    name: 'arrears',
    light: Tone(foreground: 0xFF7A1212, background: 0xFFFFE1E0),
    dark: Tone(foreground: 0xFFFFB4AE, background: 0xFF4A1010),
  ),
];

TokenSpec tokenSpec(String name) =>
    tokenSpecs.firstWhere((spec) => spec.name == name);

double _channel(int value) {
  final c = value / 255;
  return c <= 0.03928
      ? c / 12.92
      : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
}

/// WCAG 2.x relative luminance.
double luminance(int argb) =>
    0.2126 * _channel((argb >> 16) & 0xFF) +
    0.7152 * _channel((argb >> 8) & 0xFF) +
    0.0722 * _channel(argb & 0xFF);

/// WCAG 2.x contrast ratio, 1 to 21.
double contrastRatio(int a, int b) {
  final la = luminance(a);
  final lb = luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}
