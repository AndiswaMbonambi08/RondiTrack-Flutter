import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/money/cents.dart';
import 'package:ronditrack/features/payout/domain/payout_actions.dart';
import 'package:ronditrack/features/payout/domain/payout_order.dart';
import 'package:ronditrack/features/payout/domain/payout_status.dart';
import 'package:ronditrack/features/stokvel/domain/enums.dart';

PayoutOrder orderWith(PayoutStatus status) => PayoutOrder(
  stokvelId: 's',
  cycleId: 'c',
  entries: [
    PayoutEntry(
      memberId: 'a',
      memberName: 'A',
      position: 1,
      amount: const Cents(100),
      paidOn: null,
      status: status,
    ),
  ],
);

void main() {
  test('Treasurer and Admin can record while someone is Next', () {
    final order = orderWith(PayoutStatus.next);
    expect(canRecordPayout(role: StokvelRole.treasurer, order: order), isTrue);
    expect(canRecordPayout(role: StokvelRole.admin, order: order), isTrue);
  });

  test('nobody records when the API says no one is Next', () {
    final order = orderWith(PayoutStatus.paid);
    expect(canRecordPayout(role: StokvelRole.treasurer, order: order), isFalse);
    expect(canRecordPayout(role: StokvelRole.admin, order: order), isFalse);
  });

  test('a Member, an unknown role and an unknown membership cannot', () {
    final order = orderWith(PayoutStatus.next);
    expect(canRecordPayout(role: StokvelRole.member, order: order), isFalse);
    expect(canRecordPayout(role: StokvelRole.unknown, order: order), isFalse);
    expect(canRecordPayout(role: null, order: order), isFalse);
  });
}
