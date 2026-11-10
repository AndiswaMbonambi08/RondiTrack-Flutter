import 'package:ronditrack/features/stokvel/domain/actions.dart';
import 'package:ronditrack/features/stokvel/domain/enums.dart';

String cycleLabel(CycleStatus status) => switch (status) {
  CycleStatus.open => 'Open',
  CycleStatus.closed => 'Closed',
  CycleStatus.paidOut => 'Paid out',
  CycleStatus.unknown => 'Status unavailable',
};

String contributionLabel(ContributionStatus status) => switch (status) {
  ContributionStatus.pending => 'Pending',
  ContributionStatus.paid => 'Paid, awaiting confirmation',
  ContributionStatus.confirmed => 'Confirmed',
  ContributionStatus.overdue => 'Overdue',
  ContributionStatus.unknown => 'Status unavailable',
};

String roleLabel(StokvelRole role) => switch (role) {
  StokvelRole.member => 'Member',
  StokvelRole.treasurer => 'Treasurer',
  StokvelRole.unknown => 'Unknown role',
};

String actionLabel(StokvelAction action) => switch (action) {
  StokvelAction.pay => 'Pay',
  StokvelAction.uploadProof => 'Upload proof',
  StokvelAction.confirmContributions => 'Confirm contributions',
  StokvelAction.closeCycle => 'Close cycle',
  StokvelAction.recordPayout => 'Record payout',
};
