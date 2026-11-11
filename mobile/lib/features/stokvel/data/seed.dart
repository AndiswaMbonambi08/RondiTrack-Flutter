import 'package:ronditrack/core/money/cents.dart';
import 'package:ronditrack/features/stokvel/domain/enums.dart';
import 'package:ronditrack/features/stokvel/domain/models.dart';

// Same people and stokvels as the API's demo seed (README, Contract notes).
// The role lives on the membership. Amounts and contributors are fake data.
const seedMemberships = <String, List<Membership>>{
  'sipho': [
    Membership(stokvelId: 'ubuntu-savings-circle', role: StokvelRole.member),
    Membership(stokvelId: 'umoja-family-fund', role: StokvelRole.treasurer),
  ],
  'nomsa': [
    Membership(stokvelId: 'umoja-family-fund', role: StokvelRole.admin),
  ],
  'platform-admin': [],
};

const seedStokvels = <String, Stokvel>{
  'ubuntu-savings-circle': Stokvel(
    id: 'ubuntu-savings-circle',
    name: 'Ubuntu Savings Circle',
    contributionAmount: Cents(50000),
  ),
  'umoja-family-fund': Stokvel(
    id: 'umoja-family-fund',
    name: 'Umoja Family Fund',
    contributionAmount: Cents(150000),
  ),
};

final seedCycles = <String, Cycle>{
  'ubuntu-savings-circle': Cycle(
    id: 'cycle-ubuntu-3',
    number: 3,
    status: CycleStatus.open,
    dueDate: DateTime.utc(2026, 11, 30),
  ),
  'umoja-family-fund': Cycle(
    id: 'cycle-umoja-5',
    number: 5,
    status: CycleStatus.open,
    dueDate: DateTime.utc(2026, 11, 25),
  ),
};

const seedContributions = <String, List<Contribution>>{
  'ubuntu-savings-circle': [
    Contribution(
      id: 'u1',
      memberId: 'sipho',
      memberName: 'Sipho',
      amount: Cents(50000),
      status: ContributionStatus.pending,
    ),
    Contribution(
      id: 'u2',
      memberId: 'thandiwe',
      memberName: 'Thandiwe',
      amount: Cents(50000),
      status: ContributionStatus.confirmed,
    ),
    Contribution(
      id: 'u3',
      memberId: 'zanele',
      memberName: 'Zanele',
      amount: Cents(50000),
      status: ContributionStatus.confirmed,
    ),
    Contribution(
      id: 'u4',
      memberId: 'mpho',
      memberName: 'Mpho',
      amount: Cents(50000),
      status: ContributionStatus.paid,
    ),
  ],
  'umoja-family-fund': [
    Contribution(
      id: 'm1',
      memberId: 'sipho',
      memberName: 'Sipho',
      amount: Cents(150000),
      status: ContributionStatus.pending,
    ),
    Contribution(
      id: 'm2',
      memberId: 'nomsa',
      memberName: 'Nomsa',
      amount: Cents(150000),
      status: ContributionStatus.confirmed,
    ),
    Contribution(
      id: 'm3',
      memberId: 'lebo',
      memberName: 'Lebo',
      amount: Cents(150000),
      status: ContributionStatus.paid,
    ),
  ],
};

typedef HomeFigures = ({
  Cents paid,
  Cents owed,
  Cents arrears,
  DateTime? nextPayout,
});

// nextPayout is an instant (the last moment of the month in Johannesburg).
final seedFigures = <String, Map<String, HomeFigures>>{
  'sipho': {
    'ubuntu-savings-circle': (
      paid: const Cents(100000),
      owed: const Cents(50000),
      arrears: Cents.zero,
      nextPayout: DateTime.utc(2026, 11, 30, 21, 59, 59),
    ),
    'umoja-family-fund': (
      paid: const Cents(300000),
      owed: const Cents(150000),
      arrears: const Cents(50000),
      nextPayout: null,
    ),
  },
  'nomsa': {
    'umoja-family-fund': (
      paid: const Cents(450000),
      owed: Cents.zero,
      arrears: Cents.zero,
      nextPayout: DateTime.utc(2026, 11, 30, 21, 59, 59),
    ),
  },
};

// Umoja Family Fund is deliberately slow (a data bundle).
const seedDelaysMs = <String, int>{
  'ubuntu-savings-circle': 400,
  'umoja-family-fund': 3000,
};
