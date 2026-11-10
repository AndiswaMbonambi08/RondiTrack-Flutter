import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/features/stokvel/data/fake_stokvel_repository.dart';
import 'package:ronditrack/features/stokvel/data/seed.dart';
import 'package:ronditrack/features/stokvel/domain/enums.dart';

void main() {
  test('Lerato is Treasurer of one stokvel and Member of another', () async {
    final memberships = seedMemberships['lerato']!;
    expect(
      memberships.singleWhere((m) => m.stokvelId == 'mabena-family').role,
      StokvelRole.treasurer,
    );
    expect(
      memberships.singleWhere((m) => m.stokvelId == 'soweto-teachers').role,
      StokvelRole.member,
    );

    final repo = FakeStokvelRepository(personaId: 'lerato', delayScale: 0);
    expect(
      (await repo.fetchDetail('mabena-family')).role,
      StokvelRole.treasurer,
    );
    expect(
      (await repo.fetchDetail('soweto-teachers')).role,
      StokvelRole.member,
    );
  });
}
