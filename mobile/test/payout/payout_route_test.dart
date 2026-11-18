import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/app/retry.dart';
import 'package:ronditrack/app/routes.dart';
import 'package:ronditrack/core/theme/app_theme.dart';
import 'package:ronditrack/features/payout/application/payout_providers.dart';
import 'package:ronditrack/features/payout/data/fake_payout_repository.dart';
import 'package:ronditrack/features/stokvel/application/stokvel_providers.dart';
import 'package:ronditrack/features/stokvel/data/fake_stokvel_repository.dart';

import '../support/app_harness.dart';

const payoutsAddress =
    '/stokvels/umoja-family-fund/cycles/cycle-umoja-5/payouts';

void main() {
  testWidgets('the payouts address sits in the Stokvels tab', (tester) async {
    final app = await pumpApp(tester, signedInAs: 'sipho');
    await app.go(payoutsAddress);
    expect(find.text('Payouts'), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      1,
    );
  });

  testWidgets('back goes to the cycle', (tester) async {
    final app = await pumpApp(tester, signedInAs: 'sipho');
    await app.go(payoutsAddress);
    await app.back();
    expect(find.text('Cycle 5'), findsOneWidget);
  });

  testWidgets('a signed-out link to payouts survives sign-in', (tester) async {
    final app = await pumpApp(tester);
    await app.go(payoutsAddress);
    expect(find.text('Sign in to open the link you followed.'), findsOneWidget);
    await app.signInAs('sipho');
    expect(find.text('Payouts'), findsOneWidget);
  });

  testWidgets('a cold start on the address builds the cycle underneath', (
    tester,
  ) async {
    final router = createRouter(
      isSignedIn: () => true,
      initialLocation: payoutsAddress,
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        retry: appRetry,
        overrides: [
          stokvelRepositoryProvider.overrideWithValue(
            FakeStokvelRepository(personaId: 'sipho', delayScale: 0),
          ),
          payoutRepositoryProvider.overrideWithValue(
            FakePayoutRepository(personaId: 'sipho', delayScale: 0),
          ),
        ],
        child: MaterialApp.router(
          theme: buildTheme(Brightness.light),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Payouts'), findsOneWidget);
    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('Cycle 5'), findsOneWidget);
  });
}
