import 'package:ronditrack/features/payout/domain/payout_status.dart';

/// No wildcard: a new status is a compile error here until someone decides.
String payoutStatusLabel(PayoutStatus status) => switch (status) {
  PayoutStatus.paid => 'Paid out',
  PayoutStatus.next => 'Next to be paid',
  PayoutStatus.waiting => 'Waiting for turn',
  PayoutStatus.unknown => 'Status unavailable',
};
