import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/app/routes.dart';
import 'package:ronditrack/core/format_date.dart';
import 'package:ronditrack/core/money/cents.dart';
import 'package:ronditrack/core/money/money_format.dart';
import 'package:ronditrack/core/status_chip.dart';
import 'package:ronditrack/core/sync/cached_value.dart';
import 'package:ronditrack/core/sync/sync_tracker.dart';
import 'package:ronditrack/core/sync/sync_widgets.dart';
import 'package:ronditrack/core/theme/status_colors.dart';
import 'package:ronditrack/core/widgets.dart';
import 'package:ronditrack/features/home/application/home_cache_providers.dart';
import 'package:ronditrack/features/home/domain/home_entry.dart';
import 'package:ronditrack/features/payments/application/payment_providers.dart';
import 'package:ronditrack/features/payments/domain/pending_payment.dart';
import 'package:ronditrack/l10n/generated/app_localizations.dart';
import 'package:ronditrack/l10n/labels.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(ref.read(homeRefreshProvider)());
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cached = ref.watch(cachedHomeProvider);
    final sync = ref.watch(syncStateProvider(homeSyncKey));
    final refresh = ref.read(homeRefreshProvider);
    final failure = sync.failure;
    return Scaffold(
      appBar: AppBar(title: Text(l.homeTitle)),
      body: switch (cached) {
        AsyncData(value: final CachedValue<List<HomeEntry>> c) => _HomeBody(
          cached: c,
          sync: sync,
          onRefresh: refresh,
        ),
        AsyncData() when failure != null => NoCacheView(
          failure: failure,
          onRetry: () => unawaited(refresh()),
        ),
        _ => const LoadingView(),
      },
    );
  }
}

class _HomeBody extends StatelessWidget {
  const new({
    required this.cached,
    required this.sync,
    required this.onRefresh,
  });

  final CachedValue<List<HomeEntry>> cached;
  final SyncState sync;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final failure = sync.failure;
    final entries = cached.data;
    return Column(
      children: [
        if (failure != null)
          OfflineBanner(
            failure: failure,
            fetchedAt: cached.fetchedAt,
            onRetry: () => unawaited(onRefresh()),
          ),
        if (sync.refreshing) const LinearProgressIndicator(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: entries.isEmpty
                  ? [
                      Text(l.homeEmptyTitle),
                      const SizedBox(height: 8),
                      Text(l.homeEmptyHint),
                    ]
                  : [for (final e in entries) _StokvelCard(entry: e)],
            ),
          ),
        ),
      ],
    );
  }
}

class _StokvelCard extends ConsumerWidget {
  const new({required this.entry});

  final HomeEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final next = entry.nextPayout;
    // A pending payment sits beside the server totals, marked pending. It is
    // never added into them: the phone never computes money.
    final pending =
        ref.watch(pendingPaymentsProvider(entry.stokvelId)).value ??
        const <PendingPayment>[];
    return Card(
      child: InkWell(
        onTap: () => StokvelRoute(id: entry.stokvelId).go(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.name, style: Theme.of(context).textTheme.titleMedium),
              Text(l.yourRole(roleText(l, entry.role))),
              const SizedBox(height: 8),
              Text(l.paidLine(formatRands(entry.paid))),
              Text(l.owedLine(formatRands(entry.owed))),
              _ArrearsLine(entry: entry),
              for (final p in pending)
                Row(
                  children: [
                    const ExcludeSemantics(
                      child: Icon(Icons.schedule, size: 18),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(l.payPendingLabel(formatRands(p.amount))),
                    ),
                  ],
                ),
              Text(
                next == null
                    ? l.nextPayoutNone
                    : l.nextPayoutLine(formatDate(next)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArrearsLine extends StatelessWidget {
  const new({required this.entry});

  final HomeEntry entry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = l.arrearsLine(formatRands(entry.arrears));
    if (entry.arrears == Cents.zero) return Text(text);
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: StatusChip(
        label: text,
        icon: Icons.warning_amber,
        style: context.statusColors.arrears,
      ),
    );
  }
}
