import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import 'failure.dart';
import 'result.dart';

/// The one place anything thrown becomes a [Failure].
Failure toFailure(Object error) {
  if (error is Failure) return error;
  if (error is ParallelWaitError<Object?, Object?>) {
    return _fromParallel(error.errors);
  }
  if (error is DioException) return _fromDio(error);
  if (error is SocketException || error is TimeoutException) {
    return const NoAnswerFailure();
  }
  // A body our models could not read, or anything else unexpected.
  return const ServerFailure();
}

/// Runs [body] and turns anything it throws into an [Err].
Future<Result<T>> guard<T>(Future<T> Function() body) async {
  try {
    return Ok(await body());
  } on Object catch (error) {
    return Err(toFailure(error));
  }
}

Failure _fromParallel(Object? errors) {
  final inner = switch (errors) {
    final Iterable<Object?> list => list,
    (final Object? a, final Object? b) => [a, b],
    (final Object? a, final Object? b, final Object? c) => [a, b, c],
    (final Object? a, final Object? b, final Object? c, final Object? d) => [
      a,
      b,
      c,
      d,
    ],
    _ => const <Object?>[],
  };
  for (final entry in inner) {
    if (entry is AsyncError) return toFailure(entry.error);
  }
  return const ServerFailure();
}

Failure _fromDio(DioException error) {
  final response = error.response;
  if (response == null) return const NoAnswerFailure();
  return _fromResponse(response);
}

Failure _fromResponse(Response<dynamic> response) {
  final status = response.statusCode ?? 0;
  final problem = _problemOf(response.data);
  final correlationId = _string(problem['correlationId']);
  final detail = _string(problem['detail']);
  final code = _string(problem['code']);

  switch (status) {
    case 400:
      return ValidationFailure(
        detail: detail,
        fieldErrors: _fieldErrors(problem['errors']),
        correlationId: correlationId,
      );
    case 401:
      return UnauthorizedFailure(correlationId: correlationId);
    case 403:
      return ForbiddenFailure(detail: detail, correlationId: correlationId);
    case 404:
      return NotFoundFailure(correlationId: correlationId);
    case 409:
      return ConflictFailure(
        detail: detail,
        code: code,
        isStale: code == 'stale-preview',
        correlationId: correlationId,
      );
    case 412:
      return ConflictFailure(
        detail: detail,
        code: code,
        isStale: true,
        correlationId: correlationId,
      );
    case 422:
      return RuleFailure(detail: detail, correlationId: correlationId);
    case 429:
      return RateLimitedFailure(
        retryAfterSeconds: _retryAfter(response.headers),
        correlationId: correlationId,
      );
    default:
      return ServerFailure(correlationId: correlationId);
  }
}

Map<String, dynamic> _problemOf(Object? data) {
  if (data is Map<String, dynamic>) return data;
  if (data is String && data.trimLeft().startsWith('{')) {
    try {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) return decoded;
    } on FormatException {
      // Not JSON after all, so there is no problem body to read.
    }
  }
  return const {};
}

String? _string(Object? value) =>
    value is String && value.isNotEmpty ? value : null;

int? _retryAfter(Headers headers) {
  final seconds = int.tryParse(headers.value('retry-after') ?? '');
  return (seconds != null && seconds > 0) ? seconds : null;
}

Map<String, List<String>> _fieldErrors(Object? raw) {
  if (raw is! Map) return const {};
  final result = <String, List<String>>{};
  raw.forEach((key, value) {
    if (key is! String) return;
    if (value is List) {
      result[key] = value.whereType<String>().toList();
    } else if (value is String) {
      result[key] = [value];
    }
  });
  return result;
}