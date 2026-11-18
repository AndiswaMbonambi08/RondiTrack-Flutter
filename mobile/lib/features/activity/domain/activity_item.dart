import 'package:ronditrack/core/money/cents.dart';
import 'package:ronditrack/features/stokvel/domain/enums.dart';

enum ActivityKind {
  contribution('Contribution'),
  payout('Payout'),
  memberJoined('MemberJoined'),
  unknown('');

  new(this.wire);

  final String wire;

  static ActivityKind parse(String? value) => values.firstWhere(
    (e) => e != unknown && e.wire == value,
    orElse: () => unknown,
  );
}

class ActivityItem {
  const new({
    required this.id,
    required this.stokvelName,
    required this.memberName,
    this.status,
    this.kind = ActivityKind.contribution,
    this.amount,
  });

  final String id;
  final String stokvelName;
  final String memberName;

  /// Only contributions have a status.
  final ContributionStatus? status;
  final ActivityKind kind;
  final Cents? amount;
}
