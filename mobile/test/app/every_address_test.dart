import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';

typedef Address = ({String pattern, String path, int tab, String? lands});

/// Every address in the README Routes table, opened as someone who can see it.
const addresses = <Address>[
  (pattern: '/', path: '/', tab: 0, lands: null),
  (
    pattern: '/stokvels',
    path: '/stokvels',
    tab: 1,
    lands: 'Ubuntu Savings Circle',
  ),
  (
    pattern: '/stokvels/:id',
    path: '/stokvels/umoja-family-fund',
    tab: 1,
    lands: 'Umoja Family Fund',
  ),
  (
    pattern: '/stokvels/:id/cycles/:cycleId',
    path: '/stokvels/umoja-family-fund/cycles/cycle-umoja-5',
    tab: 1,
    lands: 'Cycle 5',
  ),
  (
    pattern: '/stokvels/:id/cycles/:cycleId/payouts',
    path: '/stokvels/umoja-family-fund/cycles/cycle-umoja-5/payouts',
    tab: 1,
    lands: 'Payouts',
  ),
  (pattern: '/activity', path: '/activity', tab: 2, lands: null),
  (pattern: '/profile', path: '/profile', tab: 3, lands: null),
  (pattern: '/join/:code', path: '/join/anything', tab: 0, lands: null),
];

String readme() =>
    File('README.md')
        .readAsStringSync()
        .replaceAllMapped(RegExp(r'[{<](\w+)[}>]'), (m) => ':${m[1]}');

void main() {
  for (final a in addresses) {
    testWidgets('${a.pattern} opens ${a.path}', (tester) async {
      final app = await pumpApp(tester, signedInAs: 'sipho');
      await app.go(a.path);
      expect(find.text('Page not found'), findsNothing);
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        a.tab,
      );
      final lands = a.lands;
      if (lands != null) expect(find.text(lands), findsWidgets);
    });

    test('${a.pattern} is in the README Routes table', () {
      expect(readme(), contains(a.pattern));
    });
  }

  testWidgets('/sign-in opens when signed out', (tester) async {
    final app = await pumpApp(tester);
    await app.go('/sign-in');
    expect(find.text('Sign in'), findsWidgets);
    expect(find.text('Page not found'), findsNothing);
  });
}
