import 'package:ronditrack/features/activity/domain/activity_item.dart';

abstract interface class ActivityRepository {
  Future<List<ActivityItem>> fetchActivity();
}
