import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/core/format_date.dart';
import 'package:ronditrack/core/money/money_format.dart';
import 'package:ronditrack/core/theme/status_colors.dart';
import 'package:ronditrack/core/view_state.dart';
import 'package:ronditrack/core/widgets.dart';
import 'package:ronditrack/features/payout/application/payout_providers.dart';
import 'package:ronditrack/features/payout/domain/payout_actions.dart';
import 'package:ronditrack/features/payout/domain/payout_order.dart';
import 'package:ronditrack/features/payout/domain/payout_status.dart';
import 'package:ronditrack/features/payout/presentation/payout_chips.dart';
import 'package:ronditrack/features/stokvel/application/stokvel_providers.dart';
import 'package:ronditrack/features/stokvel/domain/actions.dart';
import 'package:ronditrack/features/stokvel/domain/enums.dart';
import 'package:ronditrack/features/stokvel/presentation/labels.dart';

/// The rotation for one cycle, shown exactly as the API sends it: the order,
/// the amounts, the dates and who is Next are the server's decisions.
class PayoutsScreen extends ConsumerWidget {
  const new({required this.stokvelId, required this.cycleId, super.key});

  final String stokvelId;
  final String cycleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = payoutOrderProvider(stokvelId, cycleId);
    final state = toViewState<PayoutOrder>(
      ref.watch(provider),
      isEmpty: (order) => order.entries.isEmpty,
    );
    // The role comes from this stokvel's membership. Until it is known, no
    // treasurer action is shown.
    final detail = ref.watch(stokvelDetailProvider(stokvelId));
    final role = detail.hasValue ? detail.requireValue.role : null;
    return Scaffold(
      appBar: AppBar(title: const Text('Payouts')),
      body: switch (state) {
        ViewLoading() => const LoadingView(),
        ViewEmpty() => const _EmptyPayouts(),
        ViewData(:final data, :final refreshing) => _PayoutList(
          order: data,
          role: role,
          refreshing: refreshing,
        ),
        ViewFailure(:final message, :final failure) => FailureView(
          message: message,
          failure: failure,
          onRetry: () => ref.invalidate(provider),
        ),
      },
    );
  }
}

class _EmptyPayouts extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('No payout order for this cycle yet.'),
            SizedBox(height: 8),
            Text('It appears here once your treasurer starts the rotation.'),
          ],
        ),
      ),
    );
  }
}

class _PayoutList extends StatelessWidget {
  const new({
    required this.order,
    required this.role,
    required this.refreshing,
  });

  final PayoutOrder order;
  final StokvelRole? role;
  final bool refreshing;

  @override
  Widget build(BuildContext context) {
    final next = order.entries
        .where((e) => e.status == PayoutStatus.next)
        .firstOrNull;
    final canRecord = canRecordPayout(role: role, order: order);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          key: PageStorageKey<String>('payouts-${order.cycleId}'),
          padding: const EdgeInsets.all(16),
          children: [
            if (refreshing) const LinearProgressIndicator(),
            if (next != null) _NextBanner(entry: next),
            if (canRecord)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FilledButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Recording a payout arrives with the live API.',
                        ),
                      ),
                    ),
                    child: Text(actionLabel(StokvelAction.recordPayout)),
                  ),
                ),
              ),
            for (final entry in order.entries) _PayoutTile(entry: entry),
          ],
        ),
      ),
    );
  }
}

class _NextBanner extends StatelessWidget {
  const new({required this.entry});

  final PayoutEntry entry;

  @override
  Widget build(BuildContext context) {
    final style = context.statusColors.next;
    return Card(
      color: style.background,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'Next: ${entry.memberName}',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: style.foreground),
        ),
      ),
    );
  }
}

class _PayoutTile extends StatelessWidget {
  const new({required this.entry});

  final PayoutEntry entry;

  @override
  Widget build(BuildContext context) {
    final paidOn = entry.paidOn;
    final isNext = entry.status == PayoutStatus.next;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        side: isNext
            ? BorderSide(color: context.statusColors.next.foreground, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${entry.position}. ${entry.memberName}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(formatRands(entry.amount)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                PayoutStatusChip(status: entry.status),
                if (paidOn != null) Text('on ${formatDate(paidOn)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
