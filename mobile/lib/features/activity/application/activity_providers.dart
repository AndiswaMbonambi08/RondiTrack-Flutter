import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ronditrack/core/session/session.dart';
import 'package:ronditrack/features/activity/data/fake_activity_repository.dart';
import 'package:ronditrack/features/activity/domain/activity_item.dart';
import 'package:ronditrack/features/activity/domain/activity_repository.dart';

part 'activity_providers.g.dart';

/// The only line Week 11 changes: names the implementation.
@Riverpod(keepAlive: true)
ActivityRepository activityRepository(Ref ref) =>
    FakeActivityRepository(personaId: ref.watch(currentPersonaProvider));

@riverpod
Future<List<ActivityItem>> activityFeed(Ref ref) =>
    ref.watch(activityRepositoryProvider).fetchActivity();
