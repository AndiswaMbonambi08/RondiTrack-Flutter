import 'package:ronditrack/core/failure/failure.dart';

/// What happened to one payment. Each answer has exactly one outcome.
sealed class PaymentOutcome {
  const new();
}

/// Accepted, or the stored answer to a repeat. Removed from the outbox.
final class PaymentPaid extends PaymentOutcome {
  const new();
}

/// Refused (already paid, cycle closed, not allowed). Removed, with the reason.
final class PaymentRefused extends PaymentOutcome {
  const new(this.failure);

  final Failure failure;
}

/// A 429. Kept with its key, nothing sent before [until].
final class PaymentWaiting extends PaymentOutcome {
  const new(this.until);

  final DateTime until;
}

/// No answer. Kept with its key. Pending, never paid.
final class PaymentPending extends PaymentOutcome {
  const new();
}

/// Older than the outbox's maximum age. Never sent again.
final class PaymentExpired extends PaymentOutcome {
  const new();
}

/// Nothing to send: already resolved.
final class PaymentGone extends PaymentOutcome {
  const new();
}
