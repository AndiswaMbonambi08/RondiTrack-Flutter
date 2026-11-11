import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/core/format_date.dart';
import 'package:ronditrack/core/money/money_format.dart';
import 'package:ronditrack/core/view_state.dart';
import 'package:ronditrack/core/widgets.dart';
import 'package:ronditrack/features/home/application/home_providers.dart';
import 'package:ronditrack/features/home/domain/home_entry.dart';
import 'package:ronditrack/features/stokvel/application/stokvel_providers.dart';
import 'package:ronditrack/features/stokvel/domain/actions.dart';
import 'package:ronditrack/features/stokvel/domain/enums.dart';
import 'package:ronditrack/features/stokvel/domain/models.dart';
import 'package:ronditrack/features/stokvel/presentation/labels.dart';

class StokvelDetailScreen extends ConsumerStatefulWidget {
  const new({required this.stokvelId, super.key});

  final String stokvelId;

  @override
  ConsumerState<StokvelDetailScreen> createState() =>
      _StokvelDetailScreenState();
}

class _StokvelDetailScreenState extends ConsumerState<StokvelDetailScreen> {
  late String _id = widget.stokvelId;

  @override
  Widget build(BuildContext context) {
    final entries =
        ref.watch(homeControllerProvider).value ?? const <HomeEntry>[];
    // Keyed by id: a new id is a brand new provider state, so the previous
    // stokvel's data can never show under this one.
    final state = toViewState<StokvelDetail>(
      ref.watch(stokvelDetailProvider(_id)),
      isEmpty: (detail) => detail.contributions.isEmpty,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stokvel'),
        actions: [
          if (entries.length > 1)
            PopupMenuButton<String>(
              icon: const Icon(Icons.swap_horiz),
              tooltip: 'Switch stokvel',
              onSelected: (id) => setState(() => _id = id),
              itemBuilder: (_) => [
                for (final e in entries)
                  PopupMenuItem(value: e.stokvelId, child: Text(e.name)),
              ],
            ),
        ],
      ),
      body: switch (state) {
        ViewLoading() => const LoadingView(),
        ViewEmpty() => const Center(child: Text('No contributions yet.')),
        ViewData(:final data) => _DetailBody(detail: data),
        ViewFailure(:final message) => FailureView(
          message: message,
          onRetry: () => ref.invalidate(stokvelDetailProvider(_id)),
        ),
      },
    );
  }
}

class _DetailBody extends StatelessWidget {
  const new({required this.detail});

  final StokvelDetail detail;

  @override
  Widget build(BuildContext context) {
    final cycle = detail.cycle;
    final actions = allowedActions((
      role: detail.role,
      cycle: cycle?.status ?? CycleStatus.unknown,
      mine: detail.myContribution,
    ));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          detail.stokvel.name,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text('Your role: ${roleLabel(detail.role)}'),
        if (cycle != null)
          Text(
            'Cycle ${cycle.number}: ${cycleLabel(cycle.status)}, '
            'due ${formatDate(cycle.dueDate)}',
          ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            for (final a in StokvelAction.values)
              if (actions.contains(a))
                FilledButton.tonal(
                  onPressed: () {},
                  child: Text(actionLabel(a)),
                ),
          ],
        ),
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
