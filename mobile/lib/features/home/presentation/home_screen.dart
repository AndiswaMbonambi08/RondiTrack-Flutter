import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/core/format_date.dart';
import 'package:ronditrack/core/money/money_format.dart';
import 'package:ronditrack/core/view_state.dart';
import 'package:ronditrack/core/widgets.dart';
import 'package:ronditrack/features/home/application/home_providers.dart';
import 'package:ronditrack/features/home/domain/home_entry.dart';
import 'package:ronditrack/features/home/presentation/persona_menu.dart';
import 'package:ronditrack/features/stokvel/presentation/labels.dart';
import 'package:ronditrack/features/stokvel/presentation/stokvel_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = toViewState<List<HomeEntry>>(
      ref.watch(homeControllerProvider),
      isEmpty: (entries) => entries.isEmpty,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('RondiTrack'),
        actions: const [PersonaMenu()],
      ),
      body: switch (state) {
        ViewLoading() => const LoadingView(),
        ViewEmpty() => const _EmptyHome(),
        ViewData(:final data, :final refreshing) => RefreshIndicator(
          onRefresh: () => ref.refresh(homeControllerProvider.future),
          child: Column(
            children: [
              if (refreshing) const LinearProgressIndicator(),
              Expanded(
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [for (final e in data) _StokvelCard(entry: e)],
                ),
              ),
            ],
          ),
        ),
        ViewFailure(:final message) => FailureView(
          message: message,
          onRetry: () => ref.invalidate(homeControllerProvider),
        ),
      },
    );
  }
}

class _EmptyHome extends StatelessWidget {
  const _EmptyHome();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('You are not in any stokvels yet.'),
            SizedBox(height: 8),
            Text('Ask your treasurer for an invitation, or start a stokvel.'),
          ],
        ),
      ),
    );
  }
}

class _StokvelCard extends StatelessWidget {
  const _StokvelCard({required this.entry});

  final HomeEntry entry;

  @override
  Widget build(BuildContext context) {
    final next = entry.nextPayout;
    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => StokvelDetailScreen(stokvelId: entry.stokvelId),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text('Your role: ${roleLabel(entry.role)}'),
              const SizedBox(height: 8),
              Text('Paid: ${formatRands(entry.paid)}'),
              Text('Owed: ${formatRands(entry.owed)}'),
              Text('Arrears: ${formatRands(entry.arrears)}'),
              Text(
                next == null
                    ? 'Next payout: none scheduled'
                    : 'Next payout: ${formatDate(next)}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}