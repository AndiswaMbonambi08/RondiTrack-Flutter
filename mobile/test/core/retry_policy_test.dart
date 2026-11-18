import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/failure/failure.dart';
import 'package:ronditrack/core/failure/retry_policy.dart';

Future<void> _noSleep(Duration _) async {}

void main() {
  test('retries "no answer" and then succeeds', () async {
    var calls = 0;
    final value = await retryRead(() async {
      calls++;
      if (calls < 3) throw const NoAnswerFailure();
      return 'ok';
    }, sleep: _noSleep);
    expect(value, 'ok');
    expect(calls, 3);
  });

  test('gives up after maxAttempts', () async {
    var calls = 0;
    await expectLater(
      retryRead<void>(() async {
        calls++;
        throw const NoAnswerFailure();
      }, sleep: _noSleep),
      throwsA(isA<NoAnswerFailure>()),
    );
    expect(calls, 3);
  });

  test('never retries a 4xx or a server failure', () async {
    for (final failure in <Failure>[
      const NotFoundFailure(),
      const ForbiddenFailure(),
      const RateLimitedFailure(retryAfterSeconds: 5),
      const ConflictFailure(),
      const ServerFailure(),
    ]) {
      var calls = 0;
      await expectLater(
        retryRead<void>(() async {
          calls++;
          throw failure;
        }, sleep: _noSleep),
        throwsA(isA<Failure>()),
      );
      expect(calls, 1, reason: '$failure must not be retried');
    }
  });
}
