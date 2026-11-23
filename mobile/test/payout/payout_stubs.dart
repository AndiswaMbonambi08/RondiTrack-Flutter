import 'package:ronditrack/features/payout/domain/payout_order.dart';
import 'package:ronditrack/features/payout/domain/payout_repository.dart';

class StubPayoutRepository implements PayoutRepository {
  new(this._fetch);

  final Future<PayoutOrder> Function(String stokvelId, String cycleId) _fetch;

  @override
  Future<PayoutOrder> fetchOrder({
    required String stokvelId,
    required String cycleId,
  }) => _fetch(stokvelId, cycleId);
}
