import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/app/config.dart';
import 'package:ronditrack/app/config_provider.dart';
import 'package:ronditrack/core/database/app_database.dart';
import 'package:ronditrack/core/database/database_provider.dart';
import 'package:ronditrack/core/session/session.dart';

/// Auth for widget and provider tests: no network, no restore, no API.
/// It starts signed out, or signed in as [startAs].
class TestAuth extends Auth {
  TestAuth([this.startAs]);

  final String? startAs;
  int _count = 0;

  @override
  AuthState build() => startAs == null
      ? const SignedOut()
      : SignedIn(userId: startAs, sessionId: ++_count);

  @override
  Future<void> restore() async {}

  void signInAs(String personaId) {
    ref.read(currentPersonaProvider.notifier).select(personaId);
    state = SignedIn(userId: personaId, sessionId: ++_count);
  }

  @override
  Future<void> signOut() async => state = const SignedOut();

  @override
  Future<void> sessionEnded() async => state = const SignedOut();
}

/// The overrides every widget or provider test needs: a config, TestAuth and
/// an in-memory database. Nothing here touches the network or the disk.
List<Override> baseOverrides({
  Flavor flavor = Flavor.dev,
  String? signedInAs,
}) => [
  appConfigProvider.overrideWithValue(
    AppConfig(
      flavor: flavor,
      apiBaseUrl: 'http://localhost',
      refreshCookieName: 'rt',
    ),
  ),
  authProvider.overrideWith(() => TestAuth(signedInAs)),
  appDatabaseProvider.overrideWith((ref) {
    final db = AppDatabase(NativeDatabase.memory());
    ref.onDispose(db.close);
    return db;
  }),
];
