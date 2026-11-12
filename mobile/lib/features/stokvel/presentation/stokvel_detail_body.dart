import 'package:flutter/material.dart';
import 'package:ronditrack/app/routes.dart';
import 'package:ronditrack/core/format_date.dart';
import 'package:ronditrack/features/stokvel/domain/actions.dart';
import 'package:ronditrack/features/stokvel/domain/enums.dart';
import 'package:ronditrack/features/stokvel/domain/models.dart';
import 'package:ronditrack/features/stokvel/presentation/contribution_tile.dart';
import 'package:ronditrack/features/stokvel/presentation/labels.dart';
import 'package:ronditrack/features/stokvel/presentation/status_chips.dart';

class StokvelDetailBody extends StatelessWidget {
  const new({required this.detail, super.key});

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
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Cycle ${cycle.number}, due ${formatDate(cycle.dueDate)}'),
              CycleStatusChip(status: cycle.status),
            ],
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
        if (cycle != null)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('View cycle'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => CycleRoute(
              id: detail.stokvel.id,
              cycleId: cycle.id,
            ).go(context),
          ),
        const Divider(height: 32),
        for (final c in detail.contributions) ContributionTile(contribution: c),
      ],
    );
  }
}
