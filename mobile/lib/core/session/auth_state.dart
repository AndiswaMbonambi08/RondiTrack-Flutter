/// Three states. The compiler lists every switch that has to decide what
/// restoring means.
sealed class AuthState {
  const AuthState();
}

final class SignedOut extends AuthState {
  const new();
}

/// A refresh token may be stored but nobody knows yet if it is still good.
/// [offline] is true when the restore could not reach the API.
final class Restoring extends AuthState {
  const new({this.offline = false});

  final bool offline;
}

final class SignedIn extends AuthState {
  const new({required this.userId, required this.sessionId});

  final String? userId;

  /// Changes on every sign-in. User-scoped providers watch it, so they are
  /// rebuilt for the next person.
  final int sessionId;
}
