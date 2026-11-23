import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/app/routes.dart';
import 'package:ronditrack/core/failure/failure.dart';
import 'package:ronditrack/core/format_date.dart';
import 'package:ronditrack/core/sync/cached_value.dart';
import 'package:ronditrack/core/sync/sync_tracker.dart';
import 'package:ronditrack/core/sync/sync_widgets.dart';
import 'package:ronditrack/core/widgets.dart';
import 'package:ronditrack/features/stokvel/application/stokvel_cache_providers.dart';
import 'package:ronditrack/features/stokvel/domain/models.dart';
import 'package:ronditrack/features/stokvel/presentation/contribution_line.dart';
import 'package:ronditrack/l10n/generated/app_localizations.dart';
import 'package:ronditrack/l10n/labels.dart';

/// A cycle sits under its stokvel. A stokvel the person is not in, or a cycle
/// id from another stokvel, reads as not found.
class CycleScreen extends ConsumerStatefulWidget {
  const new({required this.stokvelId, required this.cycleId, super.key});

  final String stokvelId;
  final String cycleId;

  @override
  ConsumerState<CycleScreen> createState() => _CycleScreenState();
}

class _CycleScreenState extends ConsumerState<CycleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(ref.read(stokvelRefreshProvider)(widget.stokvelId));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final id = widget.stokvelId;
    final cached = ref.watch(cachedStokvelProvider(id));
    final sync = ref.watch(syncStateProvider(stokvelSyncKey(id)));
    final failure = sync.failure;
    void retry() => unawaited(ref.read(stokvelRefreshProvider)(id));
    return Scaffold(
      appBar: AppBar(title: Text(l.cycleTitle)),
      body: switch (cached) {
        AsyncData(value: final CachedValue<StokvelDetail> c) => Column(
          children: [
            if (failure != null)
              OfflineBanner(
                failure: failure,
                fetchedAt: c.fetchedAt,
                onRetry: retry,
              ),
            if (sync.refreshing) const LinearProgressIndicator(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.read(stokvelRefreshProvider)(id),
                child: _CycleBody(detail: c.data, cycleId: widget.cycleId),
              ),
            ),
          ],
        ),
        AsyncData() when failure is NotFoundFailure => Center(
          child: Text(l.cycleNotFound),
        ),
        AsyncData() when failure != null => NoCacheView(
          failure: failure,
          onRetry: retry,
        ),
        _ => const LoadingView(),
      },
    );
  }
}

class _CycleBody extends StatelessWidget {
  const new({required this.detail, required this.cycleId});

  final StokvelDetail detail;
  final String cycleId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cycle = detail.cycle;
    if (cycle == null || cycle.id != cycleId) {
      return ListView(children: [Center(child: Text(l.cycleNotFound))]);
    }
    return ListView(
      key: PageStorageKey<String>('cycle-$cycleId'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          detail.stokvel.name,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
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
        Text(l.contributionCount(detail.contributions.length)),
        const SizedBox(height: 8),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton(
            onPressed: () => PayoutsRoute(
              id: detail.stokvel.id,
              cycleId: cycle.id,
            ).go(context),
            child: Text(l.rotationAndPayouts),
          ),
        ),
        const Divider(height: 32),
        for (final c in detail.contributions) ContributionLine(contribution: c),
      ],
    );
  }
}