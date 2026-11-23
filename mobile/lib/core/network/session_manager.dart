import 'dart:async';

import 'package:dio/dio.dart';
import 'package:ronditrack/core/session/cookie.dart';
import 'package:ronditrack/core/session/refresh_store.dart';

const authRefreshPath = '/api/v1/auth/refresh';
const authLogoutPath = '/api/v1/auth/logout';

sealed class RefreshOutcome {
  const new();
}

final class Refreshed extends RefreshOutcome {
  const new(this.accessToken);

  final String accessToken;
}

/// The refresh endpoint said 401: the session is over.
final class Refused extends RefreshOutcome {
  const new();
}

/// No answer, a 403, 429, 500 or a bad body. Nobody is signed out for this.
final class Unavailable extends RefreshOutcome {
  const new();
}

/// The person signed out or in again while the refresh ran. Ignored.
final class Cancelled extends RefreshOutcome {
  const new();
}

/// Owns the access token (memory only), the stored refresh token and the one
/// refresh. [bare] is a client without the session interceptor, so a refresh
/// can never wait on itself.
class SessionManager {
  new({
    required this.bare,
    required this.store,
    required this.cookieName,
    this.margin = const Duration(seconds: 60),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final Dio bare;
  final RefreshTokenStore store;
  final String cookieName;
  final Duration margin;
  final DateTime Function() _clock;

  String? _accessToken;
  DateTime? _expiresAt;
  Future<RefreshOutcome>? _inFlight;
  int _epoch = 0;

  String? get accessToken => _accessToken;

  /// True a little before the token expires.
  bool get needsRefresh {
    final at = _expiresAt;
    return _accessToken != null &&
        at != null &&
        !_clock().isBefore(at.subtract(margin));
  }

  Future<bool> hasStoredToken() async => (await store.read()) != null;

  Future<void> establish({
    required String accessToken,
    required int expiresInSeconds,
    required String refreshToken,
  }) async {
    _epoch++;
    _inFlight = null;
    await store.write(refreshToken);
    _accessToken = accessToken;
    _expiresAt = _clock().add(Duration(seconds: expiresInSeconds));
  }

  /// Single flight: while one refresh runs, everyone gets that same future.
  Future<RefreshOutcome> refresh() {
    final running = _inFlight;
    if (running != null) return running;
    final started = _run();
    _inFlight = started;
    unawaited(
      started.whenComplete(() {
        if (identical(_inFlight, started)) _inFlight = null;
      }),
    );
    return started;
  }

  Future<RefreshOutcome> _run() async {
    final epoch = _epoch;
    try {
      final stored = await store.read();
      if (epoch != _epoch) return const Cancelled();
      if (stored == null) return const Refused();
      final response = await bare.post<dynamic>(
        authRefreshPath,
        options: Options(
          headers: {'Cookie': '$cookieName=$stored'},
          validateStatus: (_) => true,
        ),
      );
      if (epoch != _epoch) return const Cancelled();
      final status = response.statusCode ?? 0;
      if (status == 401) return const Refused();
      if (status != 200) return const Unavailable();
      final data = response.data;
      if (data is! Map) return const Unavailable();
      final token = data['accessToken'];
      final seconds = data['expiresInSeconds'];
      if (token is! String || seconds is! int) return const Unavailable();
      final rotated = readSetCookie(response.headers['set-cookie'], cookieName);
      await store.write(rotated);
      if (epoch != _epoch) {
        if (await store.read() == rotated) await store.clear();
        return const Cancelled();
      }
      _accessToken = token;
      _expiresAt = _clock().add(Duration(seconds: seconds));
      return Refreshed(token);
    } on Object {
      return const Unavailable();
    }
  }

  /// Forgets everything on this phone. Returns the refresh token that was
  /// stored, so the caller can tell the API afterwards.
  Future<String?> wipe() async {
    _epoch++;
    _accessToken = null;
    _expiresAt = null;
    _inFlight = null;
    final stored = await store.read();
    await store.clear();
    return stored;
  }

  /// Best effort, short timeout, never throws. Sign-out never depends on it.
  Future<void> notifyLogout(String? refreshToken) async {
    if (refreshToken == null) return;
    try {
      await bare
          .post<dynamic>(
            authLogoutPath,
            options: Options(
              headers: {'Cookie': '$cookieName=$refreshToken'},
              sendTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 5),
              validateStatus: (_) => true,
            ),
          )
          .timeout(const Duration(seconds: 5));
    } on Object {
      // The phone is already wiped. Nothing else to do.
    }
  }

  // Dev tools only (the dev flavour's menu).
  void spoilAccessToken() {
    final token = _accessToken;
    if (token != null) _accessToken = '${token}x';
  }

  void expireAccessTokenNow() {
    _expiresAt = _clock().subtract(const Duration(seconds: 1));
  }
}
