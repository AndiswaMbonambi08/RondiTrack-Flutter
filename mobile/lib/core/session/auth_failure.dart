sealed class AuthFailure implements Exception {
  const AuthFailure();
}

final class WrongCredentials extends AuthFailure {
  const new();
}

final class EmailTaken extends AuthFailure {
  const new();
}

final class NetworkDown extends AuthFailure {
  const new();
}

final class ServerFailure extends AuthFailure {
  const new();
}

/// Register worked but the sign-in straight after did not.
final class AccountCreated extends AuthFailure {
  const new();
}

final class RateLimited extends AuthFailure {
  const new(this.retryAfter);

  final Duration retryAfter;
}

final class FieldErrors extends AuthFailure {
  const new(this.errors);

  /// Lower-case field name to message.
  final Map<String, String> errors;
}
