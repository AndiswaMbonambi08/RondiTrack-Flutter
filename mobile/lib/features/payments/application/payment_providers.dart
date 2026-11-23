import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/core/database/database_provider.dart';
import 'package:ronditrack/core/network/dio_provider.dart';
import 'package:ronditrack/core/session/session.dart';
import 'package:ronditrack/features/payments/application/payment_service.dart';
import 'package:ronditrack/features/payments/data/outbox_store.dart';
import 'package:ronditrack/features/payments/data/payment_api.dart';
import 'package:ronditrack/features/payments/domain/pending_payment.dart';

final outboxStoreProvider = Provider<OutboxStore>(
  (ref) => OutboxStore(ref.watch(appDatabaseProvider)),
);

final paymentServiceProvider = Provider<PaymentService>((ref) {
  ref.watch(sessionScopeProvider);
  return PaymentService(
    store: ref.watch(outboxStoreProvider),
    api: PaymentApi(ref.watch(dioProvider)),
  );
});

/// This person's unsent payments in one stokvel, live from the database.
// Reason: the family's type is in a private riverpod library, so it cannot be
// written here without importing from lib/src.
// ignore: specify_nonobvious_property_types
final pendingPaymentsProvider = StreamProvider.autoDispose
    .family<List<PendingPayment>, String>((ref, stokvelId) {
      final userId = ref.watch(currentUserIdProvider);
      if (userId == null) return Stream.value(const <PendingPayment>[]);
      return ref
          .watch(outboxStoreProvider)
          .watch(userId: userId, stokvelId: stokvelId);
    });
