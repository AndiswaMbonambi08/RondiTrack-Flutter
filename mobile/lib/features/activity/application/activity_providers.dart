import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ronditrack/core/network/api_mode.dart';
import 'package:ronditrack/core/network/dev_session.dart';
import 'package:ronditrack/core/network/dio_provider.dart';
import 'package:ronditrack/core/session/session.dart';
import 'package:ronditrack/features/activity/data/api_activity_repository.dart';
import 'package:ronditrack/features/activity/data/fake_activity_repository.dart';
import 'package:ronditrack/features/activity/domain/activity_item.dart';
import 'package:ronditrack/features/activity/domain/activity_repository.dart';

part 'activity_providers.g.dart';

/// The only place that names the implementation: fakes or the API.
@Riverpod(keepAlive: true)
ActivityRepository activityRepository(Ref ref) {
  if (ref.watch(useFakesProvider)) {
    return FakeActivityRepository(personaId: ref.watch(currentPersonaProvider));
  }
  return ApiActivityRepository(
    ref.watch(dioProvider),
    ref.watch(devSessionProvider),
  );
}

@riverpod
Future<List<ActivityItem>> activityFeed(Ref ref) =>
    ref.watch(activityRepositoryProvider).fetchActivity();
