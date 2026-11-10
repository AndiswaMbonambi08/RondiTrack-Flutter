import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/features/stokvel/domain/actions.dart';
import 'package:ronditrack/features/stokvel/domain/enums.dart';

void main() {
  const none = <StokvelAction>{};
  final rows = <(String, ActionContext, Set<StokvelAction>)>[
    (
      'member, open, pending',
      (
        role: StokvelRole.member,
        cycle: CycleStatus.open,
        mine: ContributionStatus.pending,
      ),
      {StokvelAction.pay},
    ),
    (
      'member, open, overdue',
      (
        role: StokvelRole.member,
        cycle: CycleStatus.open,
        mine: ContributionStatus.overdue,
      ),
      {StokvelAction.pay},
    ),
    (
      'member, open, paid',
      (
        role: StokvelRole.member,
        cycle: CycleStatus.open,
        mine: ContributionStatus.paid,
      ),
      {StokvelAction.uploadProof},
    ),
    (
      'member, open, confirmed',
      (
        role: StokvelRole.member,
        cycle: CycleStatus.open,
        mine: ContributionStatus.confirmed,
      ),
      none,
    ),
    (
      'member, open, no contribution',
      (role: StokvelRole.member, cycle: CycleStatus.open, mine: null),
      none,
    ),
    (
      'member, open, unknown contribution',
      (
        role: StokvelRole.member,
        cycle: CycleStatus.open,
        mine: ContributionStatus.unknown,
      ),
      none,
    ),
    (
      'member, closed, pending',
      (
        role: StokvelRole.member,
        cycle: CycleStatus.closed,
        mine: ContributionStatus.pending,
      ),
      none,
    ),
    (
      'member, paidOut, confirmed',
      (
        role: StokvelRole.member,
        cycle: CycleStatus.paidOut,
        mine: ContributionStatus.confirmed,
      ),
      none,
    ),
    (
      'member, unknown cycle, pending',
      (
        role: StokvelRole.member,
        cycle: CycleStatus.unknown,
        mine: ContributionStatus.pending,
      ),
      none,
    ),
    (
      'treasurer, open, pending',
      (
        role: StokvelRole.treasurer,
        cycle: CycleStatus.open,
        mine: ContributionStatus.pending,
      ),
      {
        StokvelAction.pay,
        StokvelAction.confirmContributions,
        StokvelAction.closeCycle,
      },
    ),
    (
      'treasurer, open, confirmed',
      (
        role: StokvelRole.treasurer,
        cycle: CycleStatus.open,
        mine: ContributionStatus.confirmed,
      ),
      {StokvelAction.confirmContributions, StokvelAction.closeCycle},
    ),
    (
      'treasurer, closed, confirmed',
      (
        role: StokvelRole.treasurer,
        cycle: CycleStatus.closed,
        mine: ContributionStatus.confirmed,
      ),
      {StokvelAction.recordPayout},
    ),
    (
      'treasurer, paidOut, confirmed',
      (
        role: StokvelRole.treasurer,
        cycle: CycleStatus.paidOut,
        mine: ContributionStatus.confirmed,
      ),
      none,
    ),
    (
      'treasurer, unknown cycle',
      (role: StokvelRole.treasurer, cycle: CycleStatus.unknown, mine: null),
      none,
    ),
    (
      'unknown role, open, pending',
      (
        role: StokvelRole.unknown,
        cycle: CycleStatus.open,
        mine: ContributionStatus.pending,
      ),
      none,
    ),
  ];

  for (final (name, context, expected) in rows) {
    test(name, () {
      expect(allowedActions(context), expected);
    });
  }
}
