import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/failure/failure.dart';
import 'package:ronditrack/core/failure/failure_mapper.dart';

DioException _http(
  int status, {
  Object? data,
  Map<String, List<String>> headers = const {},
}) {
  final options = RequestOptions(path: '/x');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(
      requestOptions: options,
      statusCode: status,
      data: data,
      headers: Headers.fromMap(headers),
    ),
  );
}

DioException _noAnswer(DioExceptionType type) =>
    DioException(requestOptions: RequestOptions(path: '/x'), type: type);

void main() {
  group('toFailure', () {
    test('400 keeps its detail and field errors', () {
      final f =
          toFailure(
                _http(
                  400,
                  data: {
                    'detail': 'Amount is out of range.',
                    'errors': {
                      'amount': ['Too large'],
                    },
                    'correlationId': 'abc:1',
                  },
                ),
              )
              as ValidationFailure;
      expect(f.message, 'Amount is out of range.');
      expect(f.fieldErrors['amount'], ['Too large']);
      expect(f.correlationId, 'abc:1');
    });

    test('401 is unauthorised', () {
      expect(toFailure(_http(401)), isA<UnauthorizedFailure>());
    });

    test('403 shows the API message and is not a sign-out', () {
      final f =
          toFailure(_http(403, data: {'detail': 'Treasurers only.'}))
              as ForbiddenFailure;
      expect(f.message, 'Treasurers only.');
    });

    test('404 is plain "Not found", whatever the API says', () {
      final f = toFailure(
        _http(404, data: {'detail': 'You do not have access to this.'}),
      );
      expect(f, isA<NotFoundFailure>());
      expect(f.message, 'Not found');
    });

    test('409 already-closed is a conflict that is not stale', () {
      final f =
          toFailure(_http(409, data: {'code': 'already-closed'}))
              as ConflictFailure;
      expect(f.isStale, isFalse);
      expect(f.code, 'already-closed');
    });

    test('409 stale-preview is stale', () {
      final f =
          toFailure(_http(409, data: {'code': 'stale-preview'}))
              as ConflictFailure;
      expect(f.isStale, isTrue);
    });

    test('412 is a stale write', () {
      final f = toFailure(_http(412)) as ConflictFailure;
      expect(f.isStale, isTrue);
    });

    test('422 is a rule failure', () {
      expect(toFailure(_http(422)), isA<RuleFailure>());
    });

    test('429 carries the wait from Retry-After', () {
      final f =
          toFailure(
                _http(
                  429,
                  headers: {
                    'retry-after': ['42'],
                  },
                ),
              )
              as RateLimitedFailure;
      expect(f.retryAfterSeconds, 42);
      expect(f.message, contains('42'));
    });

    test('429 without Retry-After still reads well', () {
      final f = toFailure(_http(429)) as RateLimitedFailure;
      expect(f.retryAfterSeconds, isNull);
      expect(f.message, isNotEmpty);
    });

    test('500 never shows the API message, but keeps the reference', () {
      final f =
          toFailure(
                _http(
                  500,
                  data: {
                    'detail': 'NullReferenceException at Foo.cs:12',
                    'correlationId': 'trace-9',
                  },
                ),
              )
              as ServerFailure;
      expect(f.message, isNot(contains('NullReference')));
      expect(f.correlationId, 'trace-9');
    });

    test('an HTML 502 from a proxy is a server failure', () {
      final f =
          toFailure(_http(502, data: '<html>Bad Gateway</html>'))
              as ServerFailure;
      expect(f.correlationId, isNull);
    });

    test('a body the models cannot read is a server failure', () {
      expect(toFailure(const FormatException('bad')), isA<ServerFailure>());
    });

    test('timeouts and connection errors are "no answer"', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.connectionError,
      ]) {
        expect(toFailure(_noAnswer(type)), isA<NoAnswerFailure>());
      }
    });

    test('a 404 inside a ParallelWaitError is still not found', () async {
      Object? caught;
      try {
        await (Future<int>.error(_http(404)), Future<int>.value(1)).wait;
      } on Object catch (e) {
        caught = e;
      }
      expect(caught, isA<ParallelWaitError<Object?, Object?>>());
      expect(toFailure(caught!), isA<NotFoundFailure>());
    });
  });
}