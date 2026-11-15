import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ronditrack/core/money/cents.dart';
import 'package:ronditrack/features/payout/domain/payout_status.dart';

part 'payout_order.freezed.dart';

/// One person's place in the rotation, exactly as the API sends it.
@freezed
abstract class PayoutEntry with _$PayoutEntry {
  const factory({
    required String memberId,
    required String memberName,
    // 1-based, decided by the server.
    required int position,
    // The pot this member receives, decided by the server.
    required Cents amount,
    // Date-only (UTC midnight). Null until the member has been paid.
    required DateTime? paidOn,
    required PayoutStatus status,
  }) = _PayoutEntry;
}

/// The rotation for one cycle. The list is already in the server's order:
/// the app never sorts it.
@freezed
abstract class PayoutOrder with _$PayoutOrder {
  const factory({
    required String stokvelId,
    required String cycleId,
    required List<PayoutEntry> entries,
  }) = _PayoutOrder;
}
