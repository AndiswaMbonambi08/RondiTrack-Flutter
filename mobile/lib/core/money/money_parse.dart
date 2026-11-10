import 'package:ronditrack/core/money/cents.dart';

enum MoneyParseFailure { empty, tooManyDecimals, invalid }

sealed class MoneyParseResult {
  const MoneyParseResult();
}

final class MoneyParsed extends MoneyParseResult {
  const MoneyParsed(this.amount);

  final Cents amount;
}

final class MoneyRejected extends MoneyParseResult {
  const MoneyRejected(this.reason);

  final MoneyParseFailure reason;
}

// Digits, or digit groups separated by one ordinary/no-break space, then an
// optional decimal part of 1-2 digits after a comma or a full stop.
final _typedRands = RegExp(
  r'^(\d+|\d{1,3}(?:[ \u00A0]\d{3})+)(?:[,.](\d{1,2}))?$',
);
final _tooManyDecimals = RegExp(r'[,.]\d{3,}$');
final _groupSpaces = RegExp(r'[ \u00A0]');

const _maxRands = 1000000000000;

/// Parses typed rands to cents with integer arithmetic only.
///
/// Decision: a single full stop IS accepted as a decimal separator (many
/// phone keyboards have no comma), but "1,500.50" and "150." are refused.
MoneyParseResult parseRands(String input) {
  var text = input.trim();
  if (text.isEmpty) return const MoneyRejected(MoneyParseFailure.empty);
  if (text.startsWith('R') || text.startsWith('r')) {
    text = text.substring(1).trim();
  }
  final match = _typedRands.firstMatch(text);
  if (match == null) {
    return MoneyRejected(
      _tooManyDecimals.hasMatch(text)
          ? MoneyParseFailure.tooManyDecimals
          : MoneyParseFailure.invalid,
    );
  }
  final whole = int.tryParse(match.group(1)!.replaceAll(_groupSpaces, ''));
  if (whole == null || whole > _maxRands) {
    return const MoneyRejected(MoneyParseFailure.invalid);
  }
  final fraction = match.group(2) ?? '';
  final fractionCents = fraction.isEmpty
      ? 0
      : int.parse(fraction.padRight(2, '0'));
  return MoneyParsed(Cents(whole * 100 + fractionCents));
}