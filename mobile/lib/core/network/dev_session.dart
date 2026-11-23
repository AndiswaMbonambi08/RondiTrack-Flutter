import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/core/network/network_providers.dart';
import 'package:ronditrack/core/network/session_manager.dart';
import 'package:ronditrack/core/session/claims.dart';

/// Kept so the API repositories keep their shape. The session interceptor now
/// owns sign-in and refresh, so ensure() has nothing left to do. No password
/// is defined or read anywhere.
class DevSession {
  const new(this._manager);

  final SessionManager _manager;

  Future<void> ensure() async {}

  String? get userId => subjectOf(_manager.accessToken);
}

final devSessionProvider = Provider<DevSession>(
  (ref) => DevSession(ref.watch(sessionManagerProvider)),
);
