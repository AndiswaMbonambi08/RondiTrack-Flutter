import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/core/format_date.dart';
import 'package:ronditrack/core/money/money_format.dart';
import 'package:ronditrack/core/view_state.dart';
import 'package:ronditrack/core/widgets.dart';
import 'package:ronditrack/features/stokvel/application/stokvel_providers.dart';
import 'package:ronditrack/features/stokvel/domain/models.dart';
import 'package:ronditrack/features/stokvel/presentation/labels.dart';

/// A cycle sits under its stokvel. A stokvel the person is not in, or a cycle
/// id from another stokvel, reads as not found.
class CycleScreen extends ConsumerWidget {
  const new({required this.stokvelId, required this.cycleId, super.key});

  final String stokvelId;
  final String cycleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void retry() => ref.invalidate(stokvelDetailProvider(stokvelId));
    final state = toViewState<StokvelDetail>(
      ref.watch(stokvelDetailProvider(stokvelId)),
      isEmpty: (_) => false,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Cycle')),
      body: switch (state) {
        ViewLoading() => const LoadingView(),
        ViewEmpty() => FailureView(message: 'Cycle not found', onRetry: retry),
        ViewData(:final data) => _CycleBody(
          detail: data,
          cycleId: cycleId,
          onRetry: retry,
        ),
        ViewFailure(:final message) => FailureView(
          message: message,
          onRetry: retry,
        ),
      },
    );
  }
}

class _CycleBody extends StatelessWidget {
  const new({
    required this.detail,
    required this.cycleId,
    required this.onRetry,
  });

  final StokvelDetail detail;
  final String cycleId;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cycle = detail.cycle;
    if (cycle == null || cycle.id != cycleId) {
      return FailureView(message: 'Cycle not found', onRetry: onRetry);
    }
    return ListView(
      key: PageStorageKey<String>('cycle-$cycleId'),
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          detail.stokvel.name,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text('Cycle ${cycle.number}: ${cycleLabel(cycle.status)}'),
        Text('Due ${formatDate(cycle.dueDate)}'),
        const Divider(height: 32),
        for (final c in detail.contributions)
          ListTile(
            title: Text(c.memberName),
            subtitle: Text(contributionLabel(c.status)),
            trailing: Text(formatRands(c.amount)),
          ),
      ],
    );
  }
}
