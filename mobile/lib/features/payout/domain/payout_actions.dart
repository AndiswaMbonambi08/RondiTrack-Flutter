import 'package:ronditrack/features/payout/domain/payout_order.dart';
import 'package:ronditrack/features/payout/domain/payout_status.dart';
import 'package:ronditrack/features/stokvel/domain/enums.dart';

/// Treasurer and Admin of THIS stokvel may record a payout, and only while the
/// API says someone is Next. The role is the one from that stokvel's
/// membership. No wildcard over a role: a new role is a compile error here
/// until someone decides. A null role (membership not known yet) can do
/// nothing.
bool canRecordPayout({required StokvelRole? role, required PayoutOrder order}) {
  final someoneIsNext = order.entries.any((e) => e.status == PayoutStatus.next);
  return switch (role) {
    null => false,
    StokvelRole.treasurer || StokvelRole.admin => someoneIsNext,
    StokvelRole.member || StokvelRole.unknown => false,
  };
}
