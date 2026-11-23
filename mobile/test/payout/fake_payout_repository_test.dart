import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/core/errors.dart';
import 'package:ronditrack/features/payout/data/fake_payout_repository.dart';
import 'package:ronditrack/features/payout/data/payout_seed.dart';
import 'package:ronditrack/features/payout/domain/payout_status.dart';

void main() {
  FakePayoutRepository repo(String persona) =>
      FakePayoutRepository(personaId: persona, delayScale: 0);

  test('a member gets the order as seeded, in the seeded order', () async {
    final order = await repo('sipho')
        .fetchOrder(stokvelId: 'umoja-family-fund', cycleId: 'cycle-umoja-5');
    expect(order.entries, seedPayoutOrders['umoja-family-fund']);
    expect(order.entries.map((e) => e.status), [
      PayoutStatus.paid,
      PayoutStatus.next,
      PayoutStatus.waiting,
    ]);
  });

  test('a member of the other stokvel gets that stokvel order', () async {
    final order = await repo(
      'sipho',
    ).fetchOrder(stokvelId: 'ubuntu-savings-circle', cycleId: 'cycle-ubuntu-3');
    expect(order.entries.map((e) => e.memberName), [
      'Thandiwe',
      'Zanele',
      'Mpho',
      'Sipho',
    ]);
  });

  test('a non-member gets not found, like the API 404', () {
    expect(
      repo('platform-admin')
          .fetchOrder(stokvelId: 'umoja-family-fund', cycleId: 'cycle-umoja-5'),
      throwsA(isA<NotFoundException>()),
    );
    expect(
      repo('nomsa').fetchOrder(
        stokvelId: 'ubuntu-savings-circle',
        cycleId: 'cycle-ubuntu-3',
      ),
      throwsA(isA<NotFoundException>()),
    );
  });

  test('an unknown stokvel and a cycle of another stokvel read the same', () {
    expect(
      repo('sipho').fetchOrder(stokvelId: 'no-such', cycleId: 'cycle-umoja-5'),
      throwsA(isA<NotFoundException>()),
    );
    expect(
      repo(
        'sipho',
      ).fetchOrder(stokvelId: 'umoja-family-fund', cycleId: 'cycle-ubuntu-3'),
      throwsA(isA<NotFoundException>()),
    );
  });
}
