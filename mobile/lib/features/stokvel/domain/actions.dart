import 'package:ronditrack/features/stokvel/domain/enums.dart';

enum StokvelAction {
  pay,
  uploadProof,
  confirmContributions,
  closeCycle,
  recordPayout,
}

typedef ActionContext = ({
  StokvelRole role,
  CycleStatus cycle,
  ContributionStatus? mine,
});

/// What can I do here? No wildcard over a status: a new status is a compile
/// error in this file until someone decides. Admin satisfies every Treasurer
/// check (the API's role order is Member, Treasurer, Admin).
Set<StokvelAction> allowedActions(ActionContext context) {
  final memberActions = switch ((context.cycle, context.mine)) {
    (CycleStatus.open, ContributionStatus.pending) => const {StokvelAction.pay},
    (CycleStatus.open, ContributionStatus.paid) => const {
      StokvelAction.uploadProof,
    },
    (
      CycleStatus.open,
      ContributionStatus.confirmed || ContributionStatus.unknown || null,
    ) =>
      const <StokvelAction>{},
    (
      CycleStatus.closed || CycleStatus.paidOut || CycleStatus.unknown,
      ContributionStatus.pending ||
          ContributionStatus.paid ||
          ContributionStatus.confirmed ||
          ContributionStatus.unknown ||
          null,
    ) =>
      const <StokvelAction>{},
  };

  final treasurerActions = switch ((context.role, context.cycle)) {
    (StokvelRole.treasurer || StokvelRole.admin, CycleStatus.open) => const {
      StokvelAction.confirmContributions,
      StokvelAction.closeCycle,
    },
    (StokvelRole.treasurer || StokvelRole.admin, CycleStatus.closed) => const {
      StokvelAction.recordPayout,
    },
    (
      StokvelRole.treasurer || StokvelRole.admin,
      CycleStatus.paidOut || CycleStatus.unknown,
    ) =>
      const <StokvelAction>{},
    (
      StokvelRole.member || StokvelRole.unknown,
      CycleStatus.open ||
          CycleStatus.closed ||
          CycleStatus.paidOut ||
          CycleStatus.unknown,
    ) =>
      const <StokvelAction>{},
  };

  return switch (context.role) {
    StokvelRole.unknown => const <StokvelAction>{},
    StokvelRole.member ||
    StokvelRole.treasurer ||
    StokvelRole.admin => {...memberActions, ...treasurerActions},
  };
}
