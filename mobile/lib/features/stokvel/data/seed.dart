import 'package:ronditrack/core/money/cents.dart';
import 'package:ronditrack/features/stokvel/domain/enums.dart';
import 'package:ronditrack/features/stokvel/domain/models.dart';

// Same people as the API's seed personas. The role lives on the membership.
const seedMemberships = <String, List<Membership>>{
  'lerato': [
    Membership(stokvelId: 'mabena-family', role: StokvelRole.treasurer),
    Membership(stokvelId: 'soweto-teachers', role: StokvelRole.member),
  ],
  'thabo': [
    Membership(stokvelId: 'mabena-family', role: StokvelRole.member),
    Membership(stokvelId: 'soweto-teachers', role: StokvelRole.member),
  ],
  'sipho': [],
};

const seedStokvels = <String, Stokvel>{
  'mabena-family': Stokvel(
    id: 'mabena-family',
    name: 'Mabena Family',
    contributionAmount: Cents(50000),
  ),
  'soweto-teachers': Stokvel(
    id: 'soweto-teachers',
    name: 'Soweto Teachers',
    contributionAmount: Cents(150000),
  ),
};

final seedCycles = <String, Cycle>{
  'mabena-family': Cycle(
    id: 'cycle-mabena-3',
    number: 3,
    status: CycleStatus.open,
    dueDate: DateTime.utc(2026, 11, 30),
  ),
  'soweto-teachers': Cycle(
    id: 'cycle-soweto-5',
    number: 5,
    status: CycleStatus.open,
    dueDate: DateTime.utc(2026, 11, 25),
  ),
};

const seedContributions = <String, List<Contribution>>{
  'mabena-family': [
    Contribution(
      id: 'm1',
      memberId: 'lerato',
      memberName: 'Lerato',
      amount: Cents(50000),
      status: ContributionStatus.paid,
    ),
    Contribution(
      id: 'm2',
      memberId: 'thabo',
      memberName: 'Thabo',
      amount: Cents(50000),
      status: ContributionStatus.pending,
    ),
    Contribution(
      id: 'm3',
      memberId: 'nomsa',
      memberName: 'Nomsa',
      amount: Cents(50000),
      status: ContributionStatus.confirmed,
    ),
    Contribution(
      id: 'm4',
      memberId: 'mpho',
      memberName: 'Mpho',
      amount: Cents(50000),
      status: ContributionStatus.confirmed,
    ),
  ],
  'soweto-teachers': [
    Contribution(
      id: 's1',
      memberId: 'lerato',
      memberName: 'Lerato',
      amount: Cents(150000),
      status: ContributionStatus.overdue,
    ),
    Contribution(
      id: 's2',
      memberId: 'thabo',
      memberName: 'Thabo',
      amount: Cents(150000),
      status: ContributionStatus.overdue,
    ),
    Contribution(
      id: 's3',
      memberId: 'zanele',
      memberName: 'Zanele',
      amount: Cents(150000),
      status: ContributionStatus.confirmed,
    ),
  ],
};

typedef HomeFigures = ({
  Cents paid,
  Cents owed,
  Cents arrears,
  DateTime? nextPayout,
});

final seedFigures = <String, Map<String, HomeFigures>>{
  'lerato': {
    'mabena-family': (
      paid: const Cents(150000),
      owed: Cents.zero,
      arrears: Cents.zero,
      nextPayout: DateTime.utc(2026, 11, 30),
    ),
    'soweto-teachers': (
      paid: const Cents(300000),
      owed: const Cents(200000),
      arrears: const Cents(50000),
      nextPayout: null,
    ),
  },
  'thabo': {
    'mabena-family': (
      paid: const Cents(100000),
      owed: const Cents(50000),
      arrears: Cents.zero,
      nextPayout: DateTime.utc(2026, 11, 30),
    ),
    'soweto-teachers': (
      paid: Cents.zero,
      owed: const Cents(150000),
      arrears: const Cents(150000),
      nextPayout: null,
    ),
  },
};

// Soweto Teachers is deliberately slow (a data bundle).
const seedDelaysMs = <String, int>{
  'mabena-family': 400,
  'soweto-teachers': 3000,
};