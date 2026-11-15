import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/features/stokvel/domain/actions.dart';
import 'package:ronditrack/features/stokvel/presentation/labels.dart';

import '../support/app_harness.dart';

const ubuntu = 'ubuntu-savings-circle';
const umoja = 'umoja-family-fund';
const ubuntuCycle = 'cycle-ubuntu-3';
const umojaCycle = 'cycle-umoja-5';
const notFound = 'Stokvel not found';

typedef HomeRow = ({String persona, List<String> shows, List<String> hides});
typedef StokvelRow = ({
  String persona,
  String stokvel,
  bool found,
  bool treasurerActions,
});
typedef PayoutRow = ({
  String persona,
  String stokvel,
  String cycle,
  bool found,
  bool recordPayout,
});

const homeTable = <HomeRow>[
  (
    persona: 'sipho',
    shows: [
      'Ubuntu Savings Circle',
      'Umoja Family Fund',
      'Your role: Member',
      'Your role: Treasurer',
    ],
    hides: ['You are not in any stokvels yet.'],
  ),
  (
    persona: 'mpho',
    shows: ['Ubuntu Savings Circle', 'Your role: Member'],
    hides: [
      'Umoja Family Fund',
      'Your role: Treasurer',
      'You are not in any stokvels yet.',
    ],
  ),
  (
    persona: 'platform-admin',
    shows: [
      'You are not in any stokvels yet.',
      'Ask your treasurer for an invitation, or start a stokvel.',
    ],
    hides: ['Ubuntu Savings Circle', 'Umoja Family Fund'],
  ),
];

const stokvelTable = <StokvelRow>[
  (persona: 'sipho', stokvel: umoja, found: true, treasurerActions: true),
  (persona: 'sipho', stokvel: ubuntu, found: true, treasurerActions: false),
  (persona: 'mpho', stokvel: ubuntu, found: true, treasurerActions: false),
  (persona: 'mpho', stokvel: umoja, found: false, treasurerActions: false),
  (
    persona: 'platform-admin',
    stokvel: ubuntu,
    found: false,
    treasurerActions: false,
  ),
  (
    persona: 'platform-admin',
    stokvel: umoja,
    found: false,
    treasurerActions: false,
  ),
];

const payoutTable = <PayoutRow>[
  (
    persona: 'sipho',
    stokvel: umoja,
    cycle: umojaCycle,
    found: true,
    recordPayout: true,
  ),
  (
    persona: 'sipho',
    stokvel: ubuntu,
    cycle: ubuntuCycle,
    found: true,
    recordPayout: false,
  ),
  (
    persona: 'mpho',
    stokvel: ubuntu,
    cycle: ubuntuCycle,
    found: true,
    recordPayout: false,
  ),
  (
    persona: 'mpho',
    stokvel: umoja,
    cycle: umojaCycle,
    found: false,
    recordPayout: false,
  ),
  (
    persona: 'platform-admin',
    stokvel: ubuntu,
    cycle: ubuntuCycle,
    found: false,
    recordPayout: false,
  ),
  (
    persona: 'platform-admin',
    stokvel: umoja,
    cycle: umojaCycle,
    found: false,
    recordPayout: false,
  ),
];

void main() {
  final confirm = actionLabel(StokvelAction.confirmContributions);
  final close = actionLabel(StokvelAction.closeCycle);
  final record = actionLabel(StokvelAction.recordPayout);

  group('Home', () {
    for (final row in homeTable) {
      testWidgets('as ${row.persona}', (tester) async {
        await pumpApp(tester, signedInAs: row.persona);
        for (final text in row.shows) {
          expect(find.text(text), findsOneWidget, reason: text);
        }
        for (final text in row.hides) {
          expect(find.text(text), findsNothing, reason: text);
        }
      });
    }
  });

  group('a stokvel', () {
    for (final row in stokvelTable) {
      testWidgets('${row.persona} opens ${row.stokvel}', (tester) async {
        final app = await pumpApp(tester, signedInAs: row.persona);
        await app.go('/stokvels/${row.stokvel}');
        expect(find.text(notFound), row.found ? findsNothing : findsOneWidget);
        final treasurer = row.treasurerActions ? findsOneWidget : findsNothing;
        expect(find.text(confirm, skipOffstage: false), treasurer);
        expect(find.text(close, skipOffstage: false), treasurer);
      });
    }
  });

  group('the payouts view', () {
    for (final row in payoutTable) {
      testWidgets('${row.persona} opens ${row.stokvel}', (tester) async {
        final app = await pumpApp(tester, signedInAs: row.persona);
        await app.go('/stokvels/${row.stokvel}/cycles/${row.cycle}/payouts');
        expect(find.text(notFound), row.found ? findsNothing : findsOneWidget);
        expect(
          find.text(record, skipOffstage: false),
          row.recordPayout ? findsOneWidget : findsNothing,
        );
      });
    }
  });
}
