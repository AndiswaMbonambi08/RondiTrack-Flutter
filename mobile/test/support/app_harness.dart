import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/app/router.dart';
import 'package:ronditrack/core/session/session.dart';
import 'package:ronditrack/features/activity/application/activity_providers.dart';
import 'package:ronditrack/features/activity/data/fake_activity_repository.dart';
import 'package:ronditrack/features/home/application/home_providers.dart';
import 'package:ronditrack/features/home/data/fake_home_repository.dart';
import 'package:ronditrack/features/join/application/join_providers.dart';
import 'package:ronditrack/features/join/data/fake_invite_repository.dart';
import 'package:ronditrack/features/stokvel/application/stokvel_providers.dart';
import 'package:ronditrack/features/stokvel/data/fake_stokvel_repository.dart';

/// The whole app through the real router, on the real fakes with no delay.
class AppHarness {
  const new(this.tester, this.container);

  final WidgetTester tester;
  final ProviderContainer container;

  Future<void> go(String location) async {
    container.read(routerProvider).go(location);
    await tester.pumpAndSettle();
  }

  Future<void> signInAs(String personaId) async {
    container.read(authProvider.notifier).signInAs(personaId);
    await tester.pumpAndSettle();
  }

  Future<void> tapTab(String label) async {
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(label),
      ),
    );
    await tester.pumpAndSettle();
  }
}

/// Starts the app signed out. Pass [signedInAs] to sign in first.
Future<AppHarness> pumpApp(WidgetTester tester, {String? signedInAs}) async {
  await tester.pumpWidget(
    ProviderScope(
      retry: (retryCount, error) => null,
      overrides: [
        homeRepositoryProvider.overrideWith(
          (ref) => FakeHomeRepository(
            personaId: ref.watch(currentPersonaProvider),
            delayScale: 0,
          ),
        ),
        stokvelRepositoryProvider.overrideWith(
          (ref) => FakeStokvelRepository(
            personaId: ref.watch(currentPersonaProvider),
            delayScale: 0,
          ),
        ),
        activityRepositoryProvider.overrideWith(
          (ref) => FakeActivityRepository(
            personaId: ref.watch(currentPersonaProvider),
            delayScale: 0,
          ),
        ),
        inviteRepositoryProvider.overrideWith(
          (ref) => FakeInviteRepository(
            personaId: ref.watch(currentPersonaProvider),
            delayScale: 0,
          ),
        ),
      ],
      child: Consumer(
        builder: (context, ref, _) =>
            MaterialApp.router(routerConfig: ref.watch(routerProvider)),
      ),
    ),
  );
  await tester.pumpAndSettle();
  final container = ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
  );
  final harness = AppHarness(tester, container);
  if (signedInAs != null) await harness.signInAs(signedInAs);
  return harness;
}
