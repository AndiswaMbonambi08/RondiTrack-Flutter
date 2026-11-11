import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/money/cents.dart';
import 'package:ronditrack/core/money/money_format.dart';
import 'package:ronditrack/core/money/money_parse.dart';

void main() {
  group('formatRands', () {
    final cases = <int, String>{
      0: 'R\u00A00,00',
      10: 'R\u00A00,10',
      15050: 'R\u00A0150,50',
      150000: 'R\u00A01\u00A0500,00',
      100000000: 'R\u00A01\u00A0000\u00A0000,00',
      -15000: '-R\u00A0150,00',
    };
    for (final MapEntry(key: cents, value: expected) in cases.entries) {
      test('$cents cents', () {
        expect(formatRands(Cents(cents)), expected);
      });
    }
  });

  group('parseRands accepts', () {
    final cases = <String, int>{
      '150': 15000,
      '150,50': 15050,
      '150,5': 15050,
      'R150': 15000,
      'R 1 500': 150000,
      '1 500,50': 150050,
      '1\u00A0500,50': 150050,
      '150.50': 15050, // decision: full stop is a decimal separator
    };
    for (final MapEntry(key: input, value: cents) in cases.entries) {
      test('"$input"', () {
        expect(
          parseRands(input),
          isA<MoneyParsed>().having((p) => p.amount.value, 'cents', cents),
        );
      });
    }
  });

  group('parseRands refuses', () {
    final cases = <String, MoneyParseFailure>{
      '1,500.50': MoneyParseFailure.invalid,
      '150,505': MoneyParseFailure.tooManyDecimals,
      '150.': MoneyParseFailure.invalid,
      '': MoneyParseFailure.empty,
      '   ': MoneyParseFailure.empty,
      'abc': MoneyParseFailure.invalid,
      '12abc': MoneyParseFailure.invalid,
    };
    for (final MapEntry(key: input, value: reason) in cases.entries) {
      test('"$input"', () {
        expect(
          parseRands(input),
          isA<MoneyRejected>().having((r) => r.reason, 'reason', reason),
        );
      });
    }
  });
}
