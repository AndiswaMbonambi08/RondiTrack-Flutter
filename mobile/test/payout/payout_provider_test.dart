import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ronditrack/app/retry.dart';
import 'package:ronditrack/core/errors.dart';
import 'package:ronditrack/core/money/cents.dart';
import 'package:ronditrack/core/view_state.dart';
import 'package:ronditrack/features/payout/application/payout_providers.dart';
import 'package:ronditrack/features/payout/domain/payout_order.dart';
import 'package:ronditrack/features/payout/domain/payout_repository.dart';
import 'package:ronditrack/features/payout/domain/payout_status.dart';

import 'payout_stubs.dart';

PayoutOrder orderOf(String stokvelId, String cycleId) =>
    PayoutOrder(stokvelId: stokvelId, cycleId: cycleId, entries: const []);

void main() {
  ProviderContainer containerWith(PayoutRepository repo) {
    final container = ProviderContainer(
      retry: appRetry,
      overrides: [payoutRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    return container;
  }

  ViewState<PayoutOrder> viewOf(ProviderContainer c, PayoutOrderProvider p) =>
      toViewState<PayoutOrder>(
        c.read(p),
        isEmpty: (order) => order.entries.isEmpty,
      );

  final provider = payoutOrderProvider('umoja-family-fund', 'cycle-umoja-5');

  test('loading, then data: each maps once', () async {
    final completer = Completer<PayoutOrder>();
    final container = containerWith(
      StubPayoutRepository((_, _) => completer.future),
    );
    container.listen(provider, (_, _) {});
    expect(viewOf(container, provider), isA<ViewLoading<PayoutOrder>>());

    completer.complete(
      orderOf('umoja-family-fund', 'cycle-umoja-5').copyWith(
        entries: [
          const PayoutEntry(
            memberId: 'a',
            memberName: 'A',
            position: 1,
            amount: Cents(100),
            paidOn: null,
            status: PayoutStatus.next,
          ),
        ],
      ),
    );
    await container.read(provider.future);
    expect(viewOf(container, provider), isA<ViewData<PayoutOrder>>());
  });

  test('empty is empty, not data', () async {
    final container = containerWith(
      StubPayoutRepository((s, c) async => orderOf(s, c)),
    );
    container.listen(provider, (_, _) {});
    await container.read(provider.future);
    expect(viewOf(container, provider), isA<ViewEmpty<PayoutOrder>>());
  });

  test('a failure maps to failure', () async {
    final container = containerWith(
      StubPayoutRepository((_, _) async => throw Exception('boom')),
    );
    container.listen(provider, (_, _) {});
    await expectLater(container.read(provider.future), throwsException);
    expect(viewOf(container, provider), isA<ViewFailure<PayoutOrder>>());
  });

  test('not found shows at once: no retry, no spinner', () async {
    var calls = 0;
    final container = containerWith(
      StubPayoutRepository((_, _) async {
        calls++;
        throw const NotFoundException();
      }),
    );
    container.listen(provider, (_, _) {});
    await expectLater(
      container.read(provider.future),
      throwsA(isA<NotFoundException>()),
    );
    expect(container.read(provider).isLoading, isFalse);
    expect(viewOf(container, provider), isA<ViewFailure<PayoutOrder>>());
    expect(calls, 1);
  });

  test('the retry policy never retries not found', () {
    expect(appRetry(0, const NotFoundException()), isNull);
    expect(appRetry(0, Exception('boom')), isNull);
  });

  test('two cycles keep separate state', () async {
    final container = containerWith(
      StubPayoutRepository((s, c) async => orderOf(s, c)),
    );
    final a = payoutOrderProvider('umoja-family-fund', 'cycle-umoja-5');
    final b = payoutOrderProvider('ubuntu-savings-circle', 'cycle-ubuntu-3');
    container
      ..listen(a, (_, _) {})
      ..listen(b, (_, _) {});
    expect((await container.read(a.future)).cycleId, 'cycle-umoja-5');
    expect((await container.read(b.future)).cycleId, 'cycle-ubuntu-3');
  });

  test('state is disposed when nothing watches it', () async {
    final container = containerWith(
      StubPayoutRepository((s, c) async => orderOf(s, c)),
    );
    final sub = container.listen(provider, (_, _) {});
    await container.read(provider.future);
    expect(container.exists(provider), isTrue);
    sub.close();
    await container.pump();
    expect(container.exists(provider), isFalse);
  });
}
