import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/features/home/application/home_providers.dart';
import 'package:ronditrack/features/home/data/fake_home_repository.dart';
import 'package:ronditrack/features/stokvel/application/stokvel_providers.dart';
import 'package:ronditrack/features/stokvel/data/fake_stokvel_repository.dart';
import 'package:ronditrack/features/stokvel/domain/models.dart';
import 'package:ronditrack/features/stokvel/presentation/stokvel_detail_screen.dart';

import '../support/stubs.dart';

void main() {
  final home = FakeHomeRepository(personaId: 'sipho', delayScale: 0);
  final sipho = FakeStokvelRepository(personaId: 'sipho', delayScale: 0);

  testWidgets('Treasurer actions appear where he is Treasurer', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [
          homeRepositoryProvider.overrideWithValue(home),
          stokvelRepositoryProvider.overrideWithValue(sipho),
        ],
        child: const MaterialApp(
          home: StokvelDetailScreen(stokvelId: 'umoja-family-fund'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Confirm contributions'), findsOneWidget);
    expect(find.text('Close cycle'), findsOneWidget);
  });

  testWidgets('and nowhere else', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [
          homeRepositoryProvider.overrideWithValue(home),
          stokvelRepositoryProvider.overrideWithValue(sipho),
        ],
        child: const MaterialApp(
          home: StokvelDetailScreen(stokvelId: 'ubuntu-savings-circle'),
        ),
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
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [
          homeRepositoryProvider.overrideWithValue(
            FakeHomeRepository(personaId: 'platform-admin', delayScale: 0),
          ),
          stokvelRepositoryProvider.overrideWithValue(
            FakeStokvelRepository(personaId: 'platform-admin', delayScale: 0),
          ),
        ],
        child: const MaterialApp(
          home: StokvelDetailScreen(stokvelId: 'umoja-family-fund'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Stokvel not found'), findsOneWidget);
    expect(find.textContaining('access'), findsNothing);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('never the wrong stokvel, not for a frame', (tester) async {
    final slow = Completer<StokvelDetail>();
    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [
          homeRepositoryProvider.overrideWithValue(home),
          stokvelRepositoryProvider.overrideWithValue(
            StubStokvelRepository(
              (id) => id == 'umoja-family-fund'
                  ? slow.future
                  : sipho.fetchDetail(id),
            ),
          ),
        ],
        child: const MaterialApp(
          home: StokvelDetailScreen(stokvelId: 'ubuntu-savings-circle'),
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
        of: find.byType(ListView),
        matching: find.text('Ubuntu Savings Circle'),
      ),
      findsNothing,
    );
  });
}
