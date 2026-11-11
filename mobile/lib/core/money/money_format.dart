import 'package:ronditrack/core/money/cents.dart';

const _nbsp = '\u00A0';

/// en-ZA: "R 1 500,00" with no-break spaces. Integer arithmetic only.
String formatRands(Cents amount) {
  final cents = amount.value;
  final negative = cents < 0;
  final abs = negative ? -cents : cents;
  final rands = (abs ~/ 100).toString();
  final grouped = StringBuffer();
  for (var i = 0; i < rands.length; i++) {
    if (i > 0 && (rands.length - i) % 3 == 0) grouped.write(_nbsp);
    grouped.write(rands[i]);
  }
  final fraction = (abs % 100).toString().padLeft(2, '0');
  final sign = negative ? '-' : '';
  return '${sign}R$_nbsp$grouped,$fraction';
}
