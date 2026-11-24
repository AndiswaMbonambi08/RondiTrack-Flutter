import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/app/routes.dart';
import 'package:ronditrack/core/session/session.dart';
import 'package:ronditrack/features/home/application/home_providers.dart';
import 'package:ronditrack/features/home/data/fake_home_repository.dart';
import 'package:ronditrack/features/stokvel/application/stokvel_providers.dart';
import 'package:ronditrack/features/stokvel/data/fake_stokvel_repository.dart';
import 'package:ronditrack/features/stokvel/domain/models.dart';
import 'package:ronditrack/features/stokvel/presentation/stokvel_detail_screen.dart';
import 'package:ronditrack/l10n/generated/app_localizations.dart';

import '../support/overrides.dart';
import '../support/stubs.dart';

Widget _screen({
  required String persona,
  required String stokvelId,
  required List<Override> repos,
}) => ProviderScope(
  retry: (retryCount, error) => null,
  overrides: [
    ...baseOverrides(signedInAs: persona),
    ...repos,
  ],
  child: MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: StokvelDetailScreen(stokvelId: stokvelId),
  ),
);

void main() {
  final home = FakeHomeRepository(personaId: 'sipho', delayScale: 0);
  final sipho = FakeStokvelRepository(personaId: 'sipho', delayScale: 0);

  testWidgets('Treasurer actions appear where he is Treasurer', (tester) async {
    await tester.pumpWidget(
      _screen(
        persona: 'sipho',
        stokvelId: 'umoja-family-fund',
        repos: [
          homeRepositoryProvider.overrideWithValue(home),
          stokvelRepositoryProvider.overrideWithValue(sipho),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Confirm contributions'), findsOneWidget);
    expect(find.text('Close cycle'), findsOneWidget);
  });

  testWidgets('and nowhere else', (tester) async {
    await tester.pumpWidget(
      _screen(
        persona: 'sipho',
        stokvelId: 'ubuntu-savings-circle',
        repos: [
          homeRepositoryProvider.overrideWithValue(home),
          stokvelRepositoryProvider.overrideWithValue(sipho),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Ubuntu Savings Circle'), findsWidgets);
    expect(find.text('Close cycle'), findsNothing);
    expect(find.text('Confirm contributions'), findsNothing);
    expect(find.text('Pay'), findsOneWidget);
  });

  testWidgets('a stokvel that is not yours reads as not found', (tester) async {
    await tester.pumpWidget(
      _screen(
        persona: 'platform-admin',
        stokvelId: 'umoja-family-fund',
        repos: [
          homeRepositoryProvider.overrideWithValue(
            FakeHomeRepository(personaId: 'platform-admin', delayScale: 0),
          ),
          stokvelRepositoryProvider.overrideWithValue(
            FakeStokvelRepository(personaId: 'platform-admin', delayScale: 0),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Stokvel not found'), findsOneWidget);
    expect(find.textContaining('access'), findsNothing);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('never the wrong stokvel, not for a frame', (tester) async {
    final slow = Completer<StokvelDetail>();
    final router = createRouter(
      readAuth: () => const SignedIn(userId: 'sipho', sessionId: 1),
      initialLocation: '/stokvels/ubuntu-savings-circle',
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [
          ...baseOverrides(signedInAs: 'sipho'),
          homeRepositoryProvider.overrideWithValue(home),
          stokvelRepositoryProvider.overrideWithValue(
            StubStokvelRepository(
              (id) => id == 'umoja-family-fund'
                  ? slow.future
                  : sipho.fetchDetail(id),
            ),
          ),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Thandiwe'), findsOneWidget); // A's contributions

    await tester.tap(find.byTooltip('Switch stokvel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Umoja Family Fund').last);
    await tester.pump(); // one frame

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Thandiwe'), findsNothing);
    expect(find.text('Zanele'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(StokvelDetailScreen),
        matching: find.text('Ubuntu Savings Circle'),
      ),
      findsNothing,
    );
  });
}
