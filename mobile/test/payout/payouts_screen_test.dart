import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/app/retry.dart';
import 'package:ronditrack/core/errors.dart';
import 'package:ronditrack/core/money/cents.dart';
import 'package:ronditrack/core/money/money_format.dart';
import 'package:ronditrack/core/status_chip.dart';
import 'package:ronditrack/core/theme/app_theme.dart';
import 'package:ronditrack/core/theme/tokens.dart';
import 'package:ronditrack/core/widgets.dart';
import 'package:ronditrack/features/payout/application/payout_providers.dart';
import 'package:ronditrack/features/payout/data/fake_payout_repository.dart';
import 'package:ronditrack/features/payout/domain/payout_order.dart';
import 'package:ronditrack/features/payout/domain/payout_repository.dart';
import 'package:ronditrack/features/payout/domain/payout_status.dart';
import 'package:ronditrack/features/payout/presentation/payouts_screen.dart';
import 'package:ronditrack/features/stokvel/application/stokvel_providers.dart';
import 'package:ronditrack/features/stokvel/data/fake_stokvel_repository.dart';

import 'payout_stubs.dart';

Future<void> pumpPayouts(
  WidgetTester tester, {
  String persona = 'sipho',
  String stokvelId = 'umoja-family-fund',
  String cycleId = 'cycle-umoja-5',
  PayoutRepository? payouts,
  Brightness brightness = Brightness.light,
  Size size = const Size(400, 800),
  double textScale = 1,
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = size;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      retry: appRetry,
      overrides: [
        payoutRepositoryProvider.overrideWithValue(
          payouts ?? FakePayoutRepository(personaId: persona, delayScale: 0),
        ),
        stokvelRepositoryProvider.overrideWithValue(
          FakeStokvelRepository(personaId: persona, delayScale: 0),
        ),
      ],
      child: MaterialApp(
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        themeMode: brightness == Brightness.dark
            ? ThemeMode.dark
            : ThemeMode.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: PayoutsScreen(stokvelId: stokvelId, cycleId: cycleId),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

PayoutEntry entry(
  String name,
  int position,
  PayoutStatus status, {
  DateTime? paidOn,
}) => PayoutEntry(
  memberId: name.toLowerCase(),
  memberName: name,
  position: position,
  amount: const Cents(450000),
  paidOn: paidOn,
  status: status,
);

PayoutRepository serving(List<PayoutEntry> entries) => StubPayoutRepository(
  (s, c) async => PayoutOrder(stokvelId: s, cycleId: c, entries: entries),
);

void main() {
  group('every state shows', () {
    testWidgets('loading', (tester) async {
      await pumpPayouts(
        tester,
        payouts: StubPayoutRepository(
          (_, _) => Completer<PayoutOrder>().future,
        ),
      );
      expect(find.byType(LoadingView), findsOneWidget);
    });

    testWidgets('empty says what to do', (tester) async {
      await pumpPayouts(tester, payouts: serving(const []));
      expect(find.text('No payout order for this cycle yet.'), findsOneWidget);
      expect(
        find.text('It appears here once your treasurer starts the rotation.'),
        findsOneWidget,
      );
    });

    testWidgets('failure has a retry that works', (tester) async {
      var calls = 0;
      await pumpPayouts(
        tester,
        payouts: StubPayoutRepository((s, c) async {
          calls++;
          if (calls == 1) throw Exception('boom');
          return FakePayoutRepository(
            personaId: 'sipho',
            delayScale: 0,
          ).fetchOrder(stokvelId: s, cycleId: c);
        }),
      );
      expect(find.byType(FailureView), findsOneWidget);
      await tester.tap(
        find.descendant(
          of: find.byType(FailureView),
          matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Next: Sipho'), findsOneWidget);
      expect(calls, 2);
    });

    testWidgets('not found reads as not found, at once', (tester) async {
      await pumpPayouts(
        tester,
        payouts: StubPayoutRepository(
          (_, _) async => throw const NotFoundException(),
        ),
      );
      expect(find.text('Stokvel not found'), findsOneWidget);
    });
  });

  testWidgets('data: order, amounts, words and who is next', (tester) async {
    await pumpPayouts(tester);
    expect(find.text('1. Nomsa'), findsOneWidget);
    expect(find.text('Next: Sipho'), findsOneWidget);
    expect(find.text(formatRands(const Cents(450000))), findsNWidgets(3));
    expect(find.text('Paid out'), findsOneWidget);
    expect(find.text('Next to be paid'), findsOneWidget);
    expect(find.text('Waiting for turn'), findsOneWidget);
  });

  testWidgets('the app shows the order as sent: it does not sort', (
    tester,
  ) async {
    await pumpPayouts(
      tester,
      payouts: serving([
        entry('Lebo', 3, PayoutStatus.waiting),
        entry(
          'Nomsa',
          1,
          PayoutStatus.paid,
          paidOn: DateTime.utc(2026, 10, 25),
        ),
        entry('Sipho', 2, PayoutStatus.next),
      ]),
    );
    final lebo = tester.getTopLeft(find.text('3. Lebo')).dy;
    final nomsa = tester.getTopLeft(find.text('1. Nomsa')).dy;
    final sipho = tester.getTopLeft(find.text('2. Sipho')).dy;
    expect(lebo, lessThan(nomsa));
    expect(nomsa, lessThan(sipho));
  });

  testWidgets('the app does not decide who is next', (tester) async {
    await pumpPayouts(
      tester,
      payouts: serving([
        entry(
          'Nomsa',
          1,
          PayoutStatus.paid,
          paidOn: DateTime.utc(2026, 10, 25),
        ),
        entry('Sipho', 2, PayoutStatus.waiting),
      ]),
    );
    expect(find.textContaining('Next:'), findsNothing);
    expect(find.text('Record payout'), findsNothing);
  });

  group('Treasurer actions follow the membership', () {
    const table =
        <({String persona, String stokvel, String cycle, bool action})>[
          (
            persona: 'sipho',
            stokvel: 'umoja-family-fund',
            cycle: 'cycle-umoja-5',
            action: true,
          ),
          (
            persona: 'sipho',
            stokvel: 'ubuntu-savings-circle',
            cycle: 'cycle-ubuntu-3',
            action: false,
          ),
          (
            persona: 'nomsa',
            stokvel: 'umoja-family-fund',
            cycle: 'cycle-umoja-5',
            action: true,
          ),
        ];
    for (final row in table) {
      testWidgets('${row.persona} in ${row.stokvel}', (tester) async {
        await pumpPayouts(
          tester,
          persona: row.persona,
          stokvelId: row.stokvel,
          cycleId: row.cycle,
        );
        expect(
          find.text('Record payout', skipOffstage: false),
          row.action ? findsOneWidget : findsNothing,
        );
      });
    }
  });

  testWidgets('360 dp at 200% text has no overflow', (tester) async {
    await pumpPayouts(tester, size: const Size(360, 640), textScale: 2);
    expect(tester.takeException(), isNull);
    expect(find.text('Next: Sipho'), findsOneWidget);
  });

  testWidgets('dark mode reads the dark tokens, light reads the light ones', (
    tester,
  ) async {
    final nextChip = find.byWidgetPredicate(
      (w) => w is StatusChip && w.label == 'Next to be paid',
    );
    await pumpPayouts(tester, brightness: Brightness.dark);
    expect(
      tester.widget<StatusChip>(nextChip).style.background,
      Color(tokenSpec('next').dark.background),
    );
    await pumpPayouts(tester);
    expect(
      tester.widget<StatusChip>(nextChip).style.background,
      Color(tokenSpec('next').light.background),
    );
  });
}
