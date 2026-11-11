import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/features/stokvel/domain/actions.dart';
import 'package:ronditrack/features/stokvel/domain/enums.dart';

ActionContext _ctx(
  StokvelRole role,
  CycleStatus cycle,
  ContributionStatus? mine,
) => (role: role, cycle: cycle, mine: mine);

void main() {
  const none = <StokvelAction>{};
  const member = StokvelRole.member;
  const treasurer = StokvelRole.treasurer;
  const open = CycleStatus.open;
  final rows = <(String, ActionContext, Set<StokvelAction>)>[
    (
      'member, open, pending',
      _ctx(member, open, ContributionStatus.pending),
      {StokvelAction.pay},
    ),
    (
      'member, open, paid',
      _ctx(member, open, ContributionStatus.paid),
      {StokvelAction.uploadProof},
    ),
    (
      'member, open, confirmed',
      _ctx(member, open, ContributionStatus.confirmed),
      none,
    ),
    ('member, open, no contribution', _ctx(member, open, null), none),
    (
      'member, open, unknown contribution',
      _ctx(member, open, ContributionStatus.unknown),
      none,
    ),
    (
      'member, closed, pending',
      _ctx(member, CycleStatus.closed, ContributionStatus.pending),
      none,
    ),
    (
      'member, paidOut, confirmed',
      _ctx(member, CycleStatus.paidOut, ContributionStatus.confirmed),
      none,
    ),
    (
      'member, unknown cycle, pending',
      _ctx(member, CycleStatus.unknown, ContributionStatus.pending),
      none,
    ),
    (
      'treasurer, open, pending',
      _ctx(treasurer, open, ContributionStatus.pending),
      {
        StokvelAction.pay,
        StokvelAction.confirmContributions,
        StokvelAction.closeCycle,
      },
    ),
    (
      'treasurer, open, confirmed',
      _ctx(treasurer, open, ContributionStatus.confirmed),
      {StokvelAction.confirmContributions, StokvelAction.closeCycle},
    ),
    (
      'treasurer, closed, confirmed',
      _ctx(treasurer, CycleStatus.closed, ContributionStatus.confirmed),
      {StokvelAction.recordPayout},
    ),
    (
      'treasurer, paidOut, confirmed',
      _ctx(treasurer, CycleStatus.paidOut, ContributionStatus.confirmed),
      none,
    ),
    (
      'treasurer, unknown cycle',
      _ctx(treasurer, CycleStatus.unknown, null),
      none,
    ),
    (
      'admin, open, confirmed (same as treasurer)',
      _ctx(StokvelRole.admin, open, ContributionStatus.confirmed),
      {StokvelAction.confirmContributions, StokvelAction.closeCycle},
    ),
    (
      'unknown role, open, pending',
      _ctx(StokvelRole.unknown, open, ContributionStatus.pending),
      none,
    ),
  ];

  for (final (name, context, expected) in rows) {
    test(name, () {
      expect(allowedActions(context), expected);
    });
  }
}
