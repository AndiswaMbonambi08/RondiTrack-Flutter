import 'package:dio/dio.dart';
import 'package:ronditrack/core/failure/retry_policy.dart';
import 'package:ronditrack/core/money/cents.dart';
import 'package:ronditrack/core/network/dev_session.dart';
import 'package:ronditrack/features/activity/data/activity_dto.dart';
import 'package:ronditrack/features/activity/domain/activity_item.dart';
import 'package:ronditrack/features/activity/domain/activity_repository.dart';

ActivityItem toActivityItem(ActivityItemDto d) => ActivityItem(
  id: d.id,
  stokvelName: d.stokvelName,
  // The API hides the actor from people who may not see it.
  memberName: d.actorName ?? 'A member',
  kind: ActivityKind.parse(d.kind),
  amount: d.amountCents == null ? null : Cents(d.amountCents!),
);

class ApiActivityRepository implements ActivityRepository {
  const new(this._dio, this._session);

  final Dio _dio;
  final DevSession _session;

  @override
  Future<List<ActivityItem>> fetchActivity() => retryRead(() async {
    await _session.ensure();
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/me/activity',
    );
    // First page only. The end marker is Contract note 1.
    return ActivityPageDto.fromJson(response.data!).items
        .map(toActivityItem)
        .toList();
  });
}
