import 'dart:async';

import 'failure.dart';
import 'failure_mapper.dart';

/// Retry is a rule over Failure types, not status codes. Only "no answer" is
/// retried. Every 4xx is final, and a 5xx is not retried because the API
/// already retries its own database (see the README for the measurement).
bool isRetryable(Failure failure) => failure is NoAnswerFailure;

typedef Sleep = Future<void> Function(Duration duration);

/// Retries a READ only. Never wrap a write in this: it could be applied twice.
Future<T> retryRead<T>(
  Future<T> Function() read, {
  int maxAttempts = 3,
  Duration baseDelay = const Duration(milliseconds: 400),
  Sleep sleep = _realSleep,
}) async {
  for (var attempt = 1; ; attempt++) {
    try {
      return await read();
    } on Object catch (error) {
      final failure = toFailure(error);
      if (attempt >= maxAttempts || !isRetryable(failure)) throw failure;
      await sleep(baseDelay * attempt);
    }
  }
}

Future<void> _realSleep(Duration duration) => Future<void>.delayed(duration);
