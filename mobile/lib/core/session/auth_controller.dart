import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/core/network/auth_api.dart';
import 'package:ronditrack/core/network/network_providers.dart';
import 'package:ronditrack/core/network/session_manager.dart';
import 'package:ronditrack/core/session/auth_failure.dart';
import 'package:ronditrack/core/session/auth_state.dart';
import 'package:ronditrack/core/session/claims.dart';

class Auth extends Notifier<AuthState> {
  int _sessions = 0;

  SessionManager get _manager => ref.read(sessionManagerProvider);

  @override
  AuthState build() {
    unawaited(Future<void>.microtask(restore));
    return const Restoring();
  }

  /// On launch, one refresh. Also the splash's Try again.
  Future<void> restore() async {
    state = const Restoring();
    if (!await _manager.hasStoredToken()) {
      state = const SignedOut();
      return;
    }
    final outcome = await _manager.refresh();
    switch (outcome) {
      case Refreshed(:final accessToken):
        state = SignedIn(
          userId: subjectOf(accessToken),
          sessionId: ++_sessions,
        );
      case Refused():
        await sessionEnded();
      case Unavailable():
        state = const Restoring(offline: true);
      case Cancelled():
        break;
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    final grant = await ref
        .read(authApiProvider)
        .login(email: email, password: password);
    await _begin(grant);
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await ref
        .read(authApiProvider)
        .register(fullName: fullName, email: email, password: password);
    try {
      await signIn(email: email, password: password);
    } on AuthFailure {
      throw const AccountCreated();
    }
  }

  Future<void> _begin(SessionGrant grant) async {
    await _manager.establish(
      accessToken: grant.accessToken,
      expiresInSeconds: grant.expiresInSeconds,
      refreshToken: grant.refreshToken,
    );
    state = SignedIn(
      userId: subjectOf(grant.accessToken),
      sessionId: ++_sessions,
    );
  }

  /// Wipes the phone first, then tells the API with a short timeout. Works
  /// with no network and never waits for the API.
  Future<void> signOut() async {
    final refreshToken = await _manager.wipe();
    ref.read(pendingJoinProvider.notifier).clear();
    state = const SignedOut();
    unawaited(_manager.notifyLogout(refreshToken));
  }

  /// Only the refresh endpoint's own 401 gets here.
  Future<void> sessionEnded() async {
    if (state is SignedOut) return;
    await _manager.wipe();
    state = const SignedOut();
  }
}

final authProvider = NotifierProvider<Auth, AuthState>(Auth.new);

/// Every user-scoped provider watches this, so each is rebuilt from the auth
/// state when the person changes. Null while signed out or restoring.
final sessionScopeProvider = Provider<int?>(
  (ref) => switch (ref.watch(authProvider)) {
    SignedIn(:final sessionId) => sessionId,
    _ => null,
  },
);

class StringSlot extends Notifier<String?> {
  @override
  String? build() => null;

  // Reason: a named command method reads better than a setter here.
  // ignore: use_setters_to_change_properties
  void set(String? value) => state = value;

  void clear() => state = null;
}

/// An invite code waiting for the person to finish signing in.
final pendingJoinProvider = NotifierProvider<StringSlot, String?>(
  StringSlot.new,
);

/// Dev flavour only: an email to fill into the sign-in form.
final signInPrefillProvider = NotifierProvider<StringSlot, String?>(
  StringSlot.new,
);
