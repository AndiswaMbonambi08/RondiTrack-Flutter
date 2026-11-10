import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/features/stokvel/domain/enums.dart';

void main() {
  test('maps every known wire string exactly', () {
    expect(CycleStatus.parse('Open'), CycleStatus.open);
    expect(CycleStatus.parse('Closed'), CycleStatus.closed);
    expect(CycleStatus.parse('PaidOut'), CycleStatus.paidOut);
    expect(ContributionStatus.parse('Pending'), ContributionStatus.pending);
    expect(ContributionStatus.parse('Paid'), ContributionStatus.paid);
    expect(ContributionStatus.parse('Confirmed'), ContributionStatus.confirmed);
    expect(ContributionStatus.parse('Overdue'), ContributionStatus.overdue);
    expect(StokvelRole.parse('Member'), StokvelRole.member);
    expect(StokvelRole.parse('Treasurer'), StokvelRole.treasurer);
  });

  test('is case sensitive and never throws on a new string', () {
    expect(CycleStatus.parse('open'), CycleStatus.unknown);
    expect(CycleStatus.parse('Archived'), CycleStatus.unknown);
    expect(ContributionStatus.parse(null), ContributionStatus.unknown);
    expect(StokvelRole.parse('Auditor'), StokvelRole.unknown);
    expect(CycleStatus.parse(''), CycleStatus.unknown);
  });
}
