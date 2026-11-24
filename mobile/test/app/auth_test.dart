import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/database/app_database.dart';
import 'package:ronditrack/core/database/database_provider.dart';
import 'package:ronditrack/core/network/dio_factory.dart';
import 'package:ronditrack/core/network/network_providers.dart';
import 'package:ronditrack/core/network/session_manager.dart';
import 'package:ronditrack/core/session/refresh_store.dart';
import 'package:ronditrack/core/session/session.dart';
import 'package:ronditrack/features/payments/data/outbox_store.dart';

import '../support/scripted_adapter.dart';

/// The real Auth, the real SessionManager and a real (in-memory) database,
/// with only the network replaced by a script.
class _Rig {
  _Rig(ResponseBody Function(RequestOptions options) responder) {
    adapter = ScriptedAdapter(responder);
    store = InMemoryRefreshTokenStore();
    db = AppDatabase(NativeDatabase.memory());
    manager = SessionManager(
      bare: buildBareDio(baseUrl: 'http://api.test', adapter: adapter),
      store: store,
      cookieName: 'rt',
    );
    container = ProviderContainer(
      overrides: [
        sessionManagerProvider.overrideWithValue(manager),
        appDatabaseProvider.overrideWithValue(db),
      ],
    );
    addTearDown(db.close);
    addTearDown(container.dispose);
  }

  late final ScriptedAdapter adapter;
  late final InMemoryRefreshTokenStore store;
  late final AppDatabase db;
  late final SessionManager manager;
  late final ProviderContainer container;

  Auth get auth => container.read(authProvider.notifier);

  /// Waits for the restore that Auth starts on its own.
  Future<AuthState> settled() async {
    for (var i = 0; i < 200; i++) {
      final s = container.read(authProvider);
      if (s is! Restoring || s.offline) return s;
      await Future<void>.delayed(Duration.zero);
    }
    fail('auth never settled');
  }
}

void main() {
  test('nothing stored: signed out, and nothing was sent', () async {
    final rig = _Rig((o) => jsonReply(200));
    expect(await rig.settled(), isA<SignedOut>());
    expect(rig.adapter.requests, isEmpty);
  });

  test('a refused refresh ends the session, clears caches, keeps the '
      'unsent payment', () async {
    final rig = _Rig((o) => jsonReply(401));
    await rig.store.write('r1');
    await rig.db.saveUserId('u1');
    await rig.db
        .into(rig.db.outboxRows)
        .insert(
          OutboxRowsCompanion.insert(
            id: 'o1',
            idempotencyKey: 'k1',
            stokvelId: 's1',
            cycleId: 'c1',
            userId: 'u1',
            amountCents: 5000,
            createdAt: DateTime.utc(2026, 11, 1),
          ),
        );

    expect(await rig.settled(), isA<SignedOut>());
    expect(await rig.store.read(), isNull);
    expect(await rig.db.savedUserId(), isNull);
    expect(await OutboxStore(rig.db).countAll(), 1);
  });

  test('no signal does not sign anyone out', () async {
    final rig = _Rig((o) => throw noSignal(o));
    await rig.store.write('r1');
    await rig.db.saveUserId('u1');

    final state = await rig.settled();
    expect(state, isA<SignedIn>());
    expect((state as SignedIn).userId, 'u1');
    expect(await rig.store.read(), 'r1');
  });

  test('a server error on refresh does not sign anyone out either', () async {
    final rig = _Rig((o) => jsonReply(500));
    await rig.store.write('r1');
    await rig.db.saveUserId('u1');

    expect(await rig.settled(), isA<SignedIn>());
    expect(await rig.store.read(), 'r1');
  });

  test('sign-out wipes the token, the database and the outbox, even with '
      'no network', () async {
    final rig = _Rig((o) => throw noSignal(o));
    expect(await rig.settled(), isA<SignedOut>());

    await rig.manager.establish(
      accessToken: 'a',
      expiresInSeconds: 900,
      refreshToken: 'r1',
    );
    await rig.db.saveUserId('u1');
    await rig.db
        .into(rig.db.outboxRows)
        .insert(
          OutboxRowsCompanion.insert(
            id: 'o1',
            idempotencyKey: 'k1',
            stokvelId: 's1',
            cycleId: 'c1',
            userId: 'u1',
            amountCents: 5000,
            createdAt: DateTime.utc(2026, 11, 1),
          ),
        );

    await rig.auth.signOut();

    expect(rig.container.read(authProvider), isA<SignedOut>());
    expect(await rig.store.read(), isNull);
    expect(rig.manager.accessToken, isNull);
    expect(await rig.db.savedUserId(), isNull);
    expect(await OutboxStore(rig.db).countAll(), 0);
  });
}
