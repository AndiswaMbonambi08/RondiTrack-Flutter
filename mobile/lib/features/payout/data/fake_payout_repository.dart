import 'package:ronditrack/core/errors.dart';
import 'package:ronditrack/features/payout/data/payout_seed.dart';
import 'package:ronditrack/features/payout/domain/payout_order.dart';
import 'package:ronditrack/features/payout/domain/payout_repository.dart';
import 'package:ronditrack/features/stokvel/data/pretend_network.dart';
import 'package:ronditrack/features/stokvel/data/seed.dart';
import 'package:ronditrack/features/stokvel/domain/models.dart';

class FakePayoutRepository implements PayoutRepository {
  /// [delayScale] 0 removes the pretend network delay (tests).
  new({required this.personaId, this.delayScale = 1});

  final String personaId;
  final double delayScale;

  @override
  Future<PayoutOrder> fetchOrder({
    required String stokvelId,
    required String cycleId,
  }) async {
    await pretendNetwork(seedDelaysMs[stokvelId] ?? 300, delayScale);
    final memberships = seedMemberships[personaId] ?? const <Membership>[];
    final isMember = memberships.any((m) => m.stokvelId == stokvelId);
    if (!isMember) throw const NotFoundException();
    final cycle = seedCycles[stokvelId];
    if (cycle == null || cycle.id != cycleId) throw const NotFoundException();
    return PayoutOrder(
      stokvelId: stokvelId,
      cycleId: cycleId,
      entries: seedPayoutOrders[stokvelId] ?? const <PayoutEntry>[],
    );
  }
}
