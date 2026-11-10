import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/features/stokvel/application/stokvel_providers.dart';
import 'package:ronditrack/features/stokvel/data/fake_stokvel_repository.dart';

import '../support/stubs.dart';

void main() {
  final fake = FakeStokvelRepository(personaId: 'lerato', delayScale: 0);

  test('two ids keep separate state', () async {
    final container = ProviderContainer(
      retry: (retryCount, error) => null,
      overrides: [stokvelRepositoryProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);
    final a = stokvelDetailProvider('mabena-family');
    final b = stokvelDetailProvider('soweto-teachers');
    container
      ..listen(a, (_, _) {})
      ..listen(b, (_, _) {});
    final detailA = await container.read(a.future);
    final detailB = await container.read(b.future);
    expect(detailA.stokvel.name, 'Mabena Family');
    expect(detailB.stokvel.name, 'Soweto Teachers');
  });

  test('two listeners on one id share one fetch', () async {
    var fetches = 0;
    final container = ProviderContainer(
      retry: (retryCount, error) => null,
      overrides: [
        stokvelRepositoryProvider.overrideWithValue(
          StubStokvelRepository((id) {
            fetches++;
            return fake.fetchDetail(id);
          }),
        ),
      ],
    );
    addTearDown(container.dispose);
    final provider = stokvelDetailProvider('mabena-family');
    container
      ..listen(provider, (_, _) {})
      ..listen(provider, (_, _) {});
    await container.read(provider.future);
    expect(fetches, 1);
  });

  test('detail state is disposed when nothing watches it', () async {
    final container = ProviderContainer(
      retry: (retryCount, error) => null,
      overrides: [stokvelRepositoryProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);
    final provider = stokvelDetailProvider('mabena-family');
    final sub = container.listen(provider, (_, _) {});
    await container.read(provider.future);
    expect(container.exists(provider), isTrue);
    sub.close();
    await container.pump();
    expect(container.exists(provider), isFalse);
  });
}