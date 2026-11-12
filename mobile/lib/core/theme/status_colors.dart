import 'package:flutter/material.dart';
import 'package:ronditrack/core/theme/tokens.dart';

/// Text and fill for one status.
class StatusStyle {
  const new({required this.foreground, required this.background});

  final Color foreground;
  final Color background;

  // Reason: a named helper that blends two styles reads better as a
  // static method than as a second constructor.
  // ignore: prefer_constructors_over_static_methods
  static StatusStyle lerp(StatusStyle a, StatusStyle b, double t) =>
      StatusStyle(
        foreground: Color.lerp(a.foreground, b.foreground, t)!,
        background: Color.lerp(a.background, b.background, t)!,
      );
}

/// Colours Material does not have: one per contribution status, cycle status
/// and arrears. Widgets ask for "arrears", never for a red.
class StatusColors extends ThemeExtension<StatusColors> {
  const new({
    required this.pending,
    required this.paid,
    required this.confirmed,
    required this.open,
    required this.closed,
    required this.paidOut,
    required this.unknown,
    required this.arrears,
  });

  // Reason: it picks the light or dark palette from the tokens, so a
  // static method says that better than a constructor would.
  // ignore: prefer_constructors_over_static_methods
  static StatusColors forBrightness(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    StatusStyle style(String name) {
      final spec = tokenSpec(name);
      final tone = dark ? spec.dark : spec.light;
      return StatusStyle(
        foreground: Color(tone.foreground),
        background: Color(tone.background),
      );
    }

    return StatusColors(
      pending: style('pending'),
      paid: style('paid'),
      confirmed: style('confirmed'),
      open: style('open'),
      closed: style('closed'),
      paidOut: style('paidOut'),
      unknown: style('unknown'),
      arrears: style('arrears'),
    );
  }

  final StatusStyle pending;
  final StatusStyle paid;
  final StatusStyle confirmed;
  final StatusStyle open;
  final StatusStyle closed;
  final StatusStyle paidOut;
  final StatusStyle unknown;
  final StatusStyle arrears;

  @override
  StatusColors copyWith({
    StatusStyle? pending,
    StatusStyle? paid,
    StatusStyle? confirmed,
    StatusStyle? open,
    StatusStyle? closed,
    StatusStyle? paidOut,
    StatusStyle? unknown,
    StatusStyle? arrears,
  }) => StatusColors(
    pending: pending ?? this.pending,
    paid: paid ?? this.paid,
    confirmed: confirmed ?? this.confirmed,
    open: open ?? this.open,
    closed: closed ?? this.closed,
    paidOut: paidOut ?? this.paidOut,
    unknown: unknown ?? this.unknown,
    arrears: arrears ?? this.arrears,
  );

  @override
  StatusColors lerp(ThemeExtension<StatusColors>? other, double t) {
    if (other is! StatusColors) return this;
    return StatusColors(
      pending: StatusStyle.lerp(pending, other.pending, t),
      paid: StatusStyle.lerp(paid, other.paid, t),
      confirmed: StatusStyle.lerp(confirmed, other.confirmed, t),
      open: StatusStyle.lerp(open, other.open, t),
      closed: StatusStyle.lerp(closed, other.closed, t),
      paidOut: StatusStyle.lerp(paidOut, other.paidOut, t),
      unknown: StatusStyle.lerp(unknown, other.unknown, t),
      arrears: StatusStyle.lerp(arrears, other.arrears, t),
    );
  }
}

extension StatusColorsContext on BuildContext {
  /// Falls back to the matching palette when a test uses a plain MaterialApp.
  StatusColors get statusColors {
    final theme = Theme.of(this);
    return theme.extension<StatusColors>() ??
        StatusColors.forBrightness(theme.brightness);
  }
}
