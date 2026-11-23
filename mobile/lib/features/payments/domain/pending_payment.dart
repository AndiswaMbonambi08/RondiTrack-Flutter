import 'package:ronditrack/core/money/cents.dart';

/// A payment the member tapped Pay on that the API has not answered yet.
class PendingPayment {
  const new({
    required this.id,
    required this.idempotencyKey,
    required this.stokvelId,
    required this.cycleId,
    required this.userId,
    required this.amount,
    required this.createdAt,
    required this.attempts,
    required this.waitUntil,
  });

  final String id;
  final String idempotencyKey;
  final String stokvelId;
  final String cycleId;
  final String userId;
  final Cents amount;
  final DateTime createdAt;
  final int attempts;

  /// Set after a 429: nothing is sent before this instant.
  final DateTime? waitUntil;
}