import 'package:ronditrack/features/activity/domain/activity_item.dart';
import 'package:ronditrack/features/activity/domain/activity_repository.dart';
import 'package:ronditrack/features/stokvel/data/pretend_network.dart';
import 'package:ronditrack/features/stokvel/data/seed.dart';
import 'package:ronditrack/features/stokvel/domain/models.dart';

class FakeActivityRepository implements ActivityRepository {
  new({required this.personaId, this.delayScale = 1});

  final String personaId;
  final double delayScale;

  @override
  Future<List<ActivityItem>> fetchActivity() async {
    await pretendNetwork(300, delayScale);
    if (personaId == 'broken') {
      throw Exception('Pretend network failure');
    }
    final memberships = seedMemberships[personaId] ?? const <Membership>[];
    return [
      for (final m in memberships)
        if (seedStokvels[m.stokvelId] case final stokvel?)
          for (final c
              in seedContributions[m.stokvelId] ?? const <Contribution>[])
            ActivityItem(
              id: c.id,
              stokvelName: stokvel.name,
              memberName: c.memberName,
              status: c.status,
            ),
    ];
  }
}
