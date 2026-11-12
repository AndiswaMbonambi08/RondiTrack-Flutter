import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ronditrack/core/view_state.dart';
import 'package:ronditrack/core/widgets.dart';
import 'package:ronditrack/features/activity/application/activity_providers.dart';
import 'package:ronditrack/features/activity/domain/activity_item.dart';
import 'package:ronditrack/features/stokvel/presentation/labels.dart';

class ActivityScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = toViewState<List<ActivityItem>>(
      ref.watch(activityFeedProvider),
      isEmpty: (items) => items.isEmpty,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Activity')),
      body: switch (state) {
        ViewLoading() => const LoadingView(),
        ViewEmpty() => const Center(child: Text('No activity yet.')),
        ViewData(:final data) => ListView(
          key: const PageStorageKey<String>('activity-list'),
          children: [
            for (final item in data)
              ListTile(
                title: Text(item.memberName),
                subtitle: Text(
                  '${item.stokvelName}: ${contributionLabel(item.status)}',
                ),
              ),
          ],
        ),
        ViewFailure(:final message) => FailureView(
          message: message,
          onRetry: () => ref.invalidate(activityFeedProvider),
        ),
      },
    );
  }
}
