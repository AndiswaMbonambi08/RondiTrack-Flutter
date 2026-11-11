import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/features/stokvel/data/fake_stokvel_repository.dart';
import 'package:ronditrack/features/stokvel/data/seed.dart';
import 'package:ronditrack/features/stokvel/domain/enums.dart';

void main() {
  test('Sipho is Treasurer of one stokvel and Member of another', () async {
    final memberships = seedMemberships['sipho']!;
    expect(
      memberships.singleWhere((m) => m.stokvelId == 'umoja-family-fund').role,
      StokvelRole.treasurer,
    );
    expect(
      memberships
          .singleWhere((m) => m.stokvelId == 'ubuntu-savings-circle')
          .role,
      StokvelRole.member,
    );

    final repo = FakeStokvelRepository(personaId: 'sipho', delayScale: 0);
    expect(
      (await repo.fetchDetail('umoja-family-fund')).role,
      StokvelRole.treasurer,
    );
    expect(
      (await repo.fetchDetail('ubuntu-savings-circle')).role,
      StokvelRole.member,
    );
  });
}
