import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/app/routes.dart';
import 'package:ronditrack/core/format_date.dart';
import 'package:ronditrack/core/money/money_format.dart';
import 'package:ronditrack/features/payments/application/payment_providers.dart';
import 'package:ronditrack/features/payments/domain/pending_payment.dart';
import 'package:ronditrack/features/payments/presentation/pay_form.dart';
import 'package:ronditrack/features/stokvel/domain/actions.dart';
import 'package:ronditrack/features/stokvel/domain/enums.dart';
import 'package:ronditrack/features/stokvel/domain/models.dart';
import 'package:ronditrack/features/stokvel/presentation/contribution_line.dart';
import 'package:ronditrack/features/stokvel/presentation/labels.dart'
    show actionLabel;
import 'package:ronditrack/l10n/generated/app_localizations.dart';
import 'package:ronditrack/l10n/labels.dart';

class StokvelDetailBody extends ConsumerWidget {
  const new({required this.detail, super.key});

  final StokvelDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final cycle = detail.cycle;
    final openCycle = cycle != null && cycle.status == CycleStatus.open
        ? cycle
        : null;
    final pending =
        ref.watch(pendingPaymentsProvider(detail.stokvel.id)).value ??
        const <PendingPayment>[];
    final actions = allowedActions((
      role: detail.role,
      cycle: cycle?.status ?? CycleStatus.unknown,
      mine: detail.myContribution,
    ));
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          detail.stokvel.name,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(l.yourRole(roleText(l, detail.role))),
        if (cycle != null)
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(l.cycleLine(cycle.number, formatDate(cycle.dueDate))),
              Chip(
                avatar: ExcludeSemantics(child: Icon(cycleStatusIcon(cycle.status))),
                label: Text(cycleStatusText(l, cycle.status)),
              ),
            ],
          ),
        const SizedBox(height: 12),
        if (openCycle != null && detail.myContribution == null)
          FilledButton.icon(
            key: const Key('open-pay-form'),
            onPressed: () => unawaited(
              showPayForm(
                context,
                stokvelId: detail.stokvel.id,
                cycleId: openCycle.id,
              ),
            ),
            icon: const Icon(Icons.payments_outlined),
            label: Text(l.payTitle),
          ),
        for (final p in pending)
          Card(
            child: ListTile(
              leading: const ExcludeSemantics(child: Icon(Icons.schedule)),
              title: Text(l.payPendingLabel(formatRands(p.amount))),
              subtitle: Text(l.payNotSent),
            ),
          ),
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
            title: Text(l.viewCycle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => CycleRoute(
              id: detail.stokvel.id,
              cycleId: cycle.id,
            ).go(context),
          ),
        const Divider(height: 32),
        if (detail.contributions.isEmpty)
          Text(l.noContributions)
        else
          for (final c in detail.contributions) ContributionLine(contribution: c),
      ],
    );
  }
}