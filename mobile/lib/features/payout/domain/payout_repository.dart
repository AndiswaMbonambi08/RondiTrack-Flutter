import 'package:ronditrack/features/payout/domain/payout_order.dart';

abstract interface class PayoutRepository {
  /// Throws NotFoundException for a missing stokvel or cycle, a cycle of
  /// another stokvel, AND a stokvel the caller is not a member of (the API's
  /// 404, which never says which).
  Future<PayoutOrder> fetchOrder({
    required String stokvelId,
    required String cycleId,
  });
}
