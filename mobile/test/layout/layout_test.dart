import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/features/stokvel/presentation/stokvel_detail_screen.dart';
import 'package:ronditrack/features/stokvel/presentation/stokvels_screen.dart';

import '../support/app_harness.dart';

void main() {
  const phone = Size(360, 640);

  // A RenderFlex overflow is thrown during layout, so a clean takeException
  // means no overflow stripe anywhere on screen.
  group('360 by 640 dp at 200% text', () {
    testWidgets('Home', (tester) async {
      final app = await pumpApp(
        tester,
        signedInAs: 'sipho',
        size: phone,
        textScale: 2,
      );
      expect(find.text('Your role: Member'), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(app.container, isNotNull);
    });

    testWidgets('the stokvel list', (tester) async {
      final app = await pumpApp(
        tester,
        signedInAs: 'sipho',
        size: phone,
        textScale: 2,
      );
      await app.tapTab('Stokvels');
      expect(find.text('Ubuntu Savings Circle'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('stokvel detail keeps every action reachable', (tester) async {
      final app = await pumpApp(
        tester,
        signedInAs: 'sipho',
        size: phone,
        textScale: 2,
      );
      await app.go('/stokvels/umoja-family-fund');
      for (final label in ['Confirm contributions', 'Close cycle']) {
        await tester.ensureVisible(find.text(label));
        expect(tester.getRect(find.text(label)).right, lessThanOrEqualTo(360));
        await tester.tap(find.text(label));
      }
      expect(tester.takeException(), isNull);
    });
  });

  group('wider windows', () {
    testWidgets('a side rail from 600 dp, a bottom bar below', (tester) async {
      final app = await pumpApp(tester, signedInAs: 'sipho');
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);

      await app.resize(const Size(700, 900));
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      for (final label in ['Home', 'Stokvels', 'Activity', 'Profile']) {
        expect(find.text(label), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('list and detail side by side on a landscape tablet', (
      tester,
    ) async {
      final app = await pumpApp(
        tester,
        signedInAs: 'sipho',
        size: const Size(1280, 800),
      );
      await app.go('/stokvels/umoja-family-fund');

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(StokvelsScreen), findsOneWidget);
      expect(find.byType(StokvelDetailScreen), findsOneWidget);
      expect(find.text('Ubuntu Savings Circle'), findsOneWidget); // the list
      expect(find.text('Confirm contributions'), findsOneWidget); // the detail
      expect(tester.takeException(), isNull);
    });

    testWidgets('turned upright it keeps the stokvel, and back returns to '
        'the list', (tester) async {
      final app = await pumpApp(
        tester,
        signedInAs: 'sipho',
        size: const Size(1280, 800),
      );
      await app.go('/stokvels/umoja-family-fund');

      await app.resize(const Size(800, 1280));
      expect(find.byType(StokvelDetailScreen), findsOneWidget);
      expect(find.byType(StokvelsScreen), findsNothing);
      expect(find.text('Confirm contributions'), findsOneWidget);

      await app.back();
      expect(find.byType(StokvelDetailScreen), findsNothing);
      expect(find.byType(StokvelsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('back from side by side returns to the list', (tester) async {
      final app = await pumpApp(
        tester,
        signedInAs: 'sipho',
        size: const Size(1280, 800),
      );
      await app.go('/stokvels/umoja-family-fund');
      await app.back();
      expect(find.text('Select a stokvel'), findsOneWidget);
      expect(find.byType(StokvelDetailScreen), findsNothing);
    });
  });
}
