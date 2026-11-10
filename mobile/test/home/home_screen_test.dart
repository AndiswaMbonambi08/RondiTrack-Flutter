import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/features/home/application/home_providers.dart';
import 'package:ronditrack/features/home/data/fake_home_repository.dart';
import 'package:ronditrack/features/home/domain/home_entry.dart';
import 'package:ronditrack/features/home/presentation/home_screen.dart';

import '../support/stubs.dart';

void main() {
  testWidgets('loading', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [
          homeRepositoryProvider.overrideWithValue(
            StubHomeRepository(() => Completer<List<HomeEntry>>().future),
          ),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('empty says so and what to do next', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [
          homeRepositoryProvider.overrideWithValue(
            FakeHomeRepository(personaId: 'sipho', delayScale: 0),
          ),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('You are not in any stokvels yet.'), findsOneWidget);
    expect(find.textContaining('Ask your treasurer'), findsOneWidget);
  });

  testWidgets('data shows a card per stokvel with the role there', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [
          homeRepositoryProvider.overrideWithValue(
            FakeHomeRepository(personaId: 'lerato', delayScale: 0),
          ),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Mabena Family'), findsOneWidget);
    expect(find.text('Soweto Teachers'), findsOneWidget);
    expect(find.text('Your role: Treasurer'), findsOneWidget);
    expect(find.text('Your role: Member'), findsOneWidget);
  });

  testWidgets('failure has a message and a retry', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [
          homeRepositoryProvider.overrideWithValue(
            StubHomeRepository(() => Future.error(Exception('boom'))),
          ),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Something went wrong. Please try again.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}