import 'package:ronditrack/core/failure/failure.dart';
import 'package:ronditrack/core/money/cents.dart';
import 'package:ronditrack/features/payments/data/outbox_store.dart';
import 'package:ronditrack/features/payments/data/payment_api.dart';
import 'package:ronditrack/features/payments/domain/payment_outcome.dart';

/// How long a payment may wait in the outbox. The API keeps an idempotency key
/// for 168 hours (Housekeeping:IdempotencyRetentionHours, M), so this is
/// shorter: after it, the payment is never sent again.
const outboxMaxAge = Duration(hours: 48);

class PaymentService {
  PaymentService({
    required this.store,
    required this.api,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final OutboxStore store;
  final PaymentApi api;
  final DateTime Function() _clock;
  final Set<String> _sending = {};

  /// Pay: the key is made now, once, when the payment is written to the
  /// outbox. Then it is sent.
  Future<PaymentOutcome> pay({
    required String stokvelId,
    required String cycleId,
    required String userId,
    required Cents amount,
  }) async {
    final entry = await store.enqueue(
      stokvelId: stokvelId,
      cycleId: cycleId,
      userId: userId,
      amount: amount,
      now: _clock().toUtc(),
    );
    return send(entry.id);
  }

  /// Every attempt sends the key that was stored with the payment: after a
  /// timeout, after Try again and after the app was killed and opened again.
  Future<PaymentOutcome> send(String id) async {
    if (!_sending.add(id)) return const PaymentPending();
    try {
      final entry = await store.find(id);
      if (entry == null) return const PaymentGone();
      final now = _clock().toUtc();
      if (now.difference(entry.createdAt) > outboxMaxAge) {
        await store.remove(id);
        return const PaymentExpired();
      }
      final waitUntil = entry.waitUntil;
      if (waitUntil != null && now.isBefore(waitUntil)) {
        return PaymentWaiting(waitUntil);
      }
      await store.recordAttempt(id);
      final failure = await api.send(
        stokvelId: entry.stokvelId,
        cycleId: entry.cycleId,
        userId: entry.userId,
        amount: entry.amount,
        idempotencyKey: entry.idempotencyKey,
      );
      if (failure == null) {
        await store.remove(id);
        return const PaymentPaid();
      }
      switch (failure) {
        case RateLimitedFailure(:final retryAfterSeconds):
          final until = now.add(Duration(seconds: retryAfterSeconds ?? 30));
          await store.setWait(id, until);
          return PaymentWaiting(until);
        case NoAnswerFailure() || ServerFailure() || UnauthorizedFailure():
          return const PaymentPending();
        case ValidationFailure() ||
            ForbiddenFailure() ||
            NotFoundFailure() ||
            ConflictFailure() ||
            RuleFailure():
          await store.remove(id);
          return PaymentRefused(failure);
      }
    } finally {
      _sending.remove(id);
    }
  }
}