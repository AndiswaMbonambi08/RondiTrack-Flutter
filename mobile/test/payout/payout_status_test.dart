import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/features/payout/domain/payout_status.dart';
import 'package:ronditrack/features/payout/presentation/payout_labels.dart';

void main() {
  test('every status the API sends maps', () {
    expect(PayoutStatus.parse('Paid'), PayoutStatus.paid);
    expect(PayoutStatus.parse('Next'), PayoutStatus.next);
    expect(PayoutStatus.parse('Waiting'), PayoutStatus.waiting);
  });

  test('a status the API adds later is unknown, not a crash', () {
    expect(PayoutStatus.parse('Skipped'), PayoutStatus.unknown);
    expect(PayoutStatus.parse(null), PayoutStatus.unknown);
    expect(PayoutStatus.parse(''), PayoutStatus.unknown);
    // Case matters, as on the wire.
    expect(PayoutStatus.parse('paid'), PayoutStatus.unknown);
  });

  test('every status has its own label in words', () {
    final labels = PayoutStatus.values.map(payoutStatusLabel).toList();
    expect(labels.every((l) => l.isNotEmpty), isTrue);
    expect(labels.toSet().length, labels.length);
  });
}
