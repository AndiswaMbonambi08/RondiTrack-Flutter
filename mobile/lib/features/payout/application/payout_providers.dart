import 'package:flutter/foundation.dart' show debugPrint;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ronditrack/core/session/session.dart';
import 'package:ronditrack/features/payout/data/fake_payout_repository.dart';
import 'package:ronditrack/features/payout/domain/payout_order.dart';
import 'package:ronditrack/features/payout/domain/payout_repository.dart';

part 'payout_providers.g.dart';

/// The only line Week 11 changes: names the implementation.
@Riverpod(keepAlive: true)
PayoutRepository payoutRepository(Ref ref) =>
    FakePayoutRepository(personaId: ref.watch(currentPersonaProvider));

/// One instance per (stokvel, cycle): two cycles never share state. The keys
/// are Strings, so a rebuild never makes a new family member.
@riverpod
Future<PayoutOrder> payoutOrder(Ref ref, String stokvelId, String cycleId) {
  // Log ids only: never a name or an amount.
  ref.onDispose(
    () => debugPrint('payoutOrder disposed stokvel=$stokvelId cycle=$cycleId'),
  );
  return ref
      .watch(payoutRepositoryProvider)
      .fetchOrder(stokvelId: stokvelId, cycleId: cycleId);
}
