/// Every way a call to the API can go wrong, with the words the person sees.
/// Each case decides its own words, once. Presentation never sees Dio.
sealed class Failure implements Exception {
  const new({this.correlationId});

  /// The API's reference for this request, when the API answered with one.
  final String? correlationId;

  /// What the person reads.
  String get message;
}

String _orElse(String? value, String fallback) =>
    (value == null || value.trim().isEmpty) ? fallback : value;

final class ValidationFailure extends Failure {
  const new({this.detail, this.fieldErrors = const {}, super.correlationId});

  final String? detail;
  final Map<String, List<String>> fieldErrors;

  @override
  String get message =>
      _orElse(detail, 'Please check what you entered and try again.');
}

final class UnauthorizedFailure extends Failure {
  const new({super.correlationId});

  @override
  String get message => 'Please sign in again.';
}

final class ForbiddenFailure extends Failure {
  const new({this.detail, super.correlationId});

  final String? detail;

  @override
  String get message =>
      _orElse(detail, "You don't have permission to do that.");
}

/// A stokvel or cycle the person is not in looks exactly like one that does not
/// exist, so this never carries the API's wording.
final class NotFoundFailure extends Failure {
  const new({super.correlationId});

  @override
  String get message => 'Not found';
}

final class ConflictFailure extends Failure {
  const new({
    this.detail,
    this.code,
    this.isStale = false,
    super.correlationId,
  });

  final String? detail;

  /// The API's problem code, for example `stale-preview` or `already-closed`.
  final String? code;

  /// True when something the person read has moved on: a 412, or a 409 with
  /// code `stale-preview`.
  final bool isStale;

  @override
  String get message => isStale
      ? 'This changed elsewhere. Refresh and try again.'
      : _orElse(
          detail,
          'That conflicts with the current state. Refresh and try again.',
        );
}

final class RuleFailure extends Failure {
  const new({this.detail, super.correlationId});

  final String? detail;

  @override
  String get message => _orElse(detail, "That isn't allowed right now.");
}

final class RateLimitedFailure extends Failure {
  const new({this.retryAfterSeconds, super.correlationId});

  /// From the API's Retry-After header, in seconds.
  final int? retryAfterSeconds;

  @override
  String get message {
    final seconds = retryAfterSeconds;
    if (seconds == null) {
      return 'Too many requests. Please wait a moment and try again.';
    }
    return 'Too many requests. Try again in $seconds '
        '${seconds == 1 ? 'second' : 'seconds'}.';
  }
}

/// A 5xx, a page from a proxy, or a body our models cannot read. The API's
/// own message is never shown, only an apology and the reference.
final class ServerFailure extends Failure {
  const new({super.correlationId});

  @override
  String get message => 'Sorry, something went wrong on our side.';
}

/// No answer at all: offline, timed out, or the server was unreachable.
final class NoAnswerFailure extends Failure {
  const new();

  @override
  String get message => "You're offline, or we couldn't reach the server.";
}
