import 'package:ronditrack/core/money/cents.dart';
import 'package:ronditrack/features/payout/domain/payout_order.dart';
import 'package:ronditrack/features/payout/domain/payout_status.dart';

// The rotation as the API sends it: already in order, with positions, the pot,
// dates and who is Next. The app never sorts or works any of it out.
// A pot is the contribution times the member count (stokvel/data/seed.dart).
final seedPayoutOrders = <String, List<PayoutEntry>>{
  'ubuntu-savings-circle': [
    PayoutEntry(
      memberId: 'thandiwe',
      memberName: 'Thandiwe',
      position: 1,
      amount: const Cents(200000),
      paidOn: DateTime.utc(2026, 9, 30),
      status: PayoutStatus.paid,
    ),
    PayoutEntry(
      memberId: 'zanele',
      memberName: 'Zanele',
      position: 2,
      amount: const Cents(200000),
      paidOn: DateTime.utc(2026, 10, 31),
      status: PayoutStatus.paid,
    ),
    const PayoutEntry(
      memberId: 'mpho',
      memberName: 'Mpho',
      position: 3,
      amount: Cents(200000),
      paidOn: null,
      status: PayoutStatus.next,
    ),
    const PayoutEntry(
      memberId: 'sipho',
      memberName: 'Sipho',
      position: 4,
      amount: Cents(200000),
      paidOn: null,
      status: PayoutStatus.waiting,
    ),
  ],
  'umoja-family-fund': [
    PayoutEntry(
      memberId: 'nomsa',
      memberName: 'Nomsa',
      position: 1,
      amount: const Cents(450000),
      paidOn: DateTime.utc(2026, 10, 25),
      status: PayoutStatus.paid,
    ),
    const PayoutEntry(
      memberId: 'sipho',
      memberName: 'Sipho',
      position: 2,
      amount: Cents(450000),
      paidOn: null,
      status: PayoutStatus.next,
    ),
    const PayoutEntry(
      memberId: 'lebo',
      memberName: 'Lebo',
      position: 3,
      amount: Cents(450000),
      paidOn: null,
      status: PayoutStatus.waiting,
    ),
  ],
};
