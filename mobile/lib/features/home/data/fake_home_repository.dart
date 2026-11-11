import 'package:ronditrack/features/home/domain/home_entry.dart';
import 'package:ronditrack/features/home/domain/home_repository.dart';
import 'package:ronditrack/features/stokvel/data/pretend_network.dart';
import 'package:ronditrack/features/stokvel/data/seed.dart';
import 'package:ronditrack/features/stokvel/domain/models.dart';

class FakeHomeRepository implements HomeRepository {
  new({required this.personaId, this.delayScale = 1});

  final String personaId;
  final double delayScale;

  @override
  Future<List<HomeEntry>> fetchHome() async {
    await pretendNetwork(500, delayScale);
    if (personaId == 'broken') {
      throw Exception('Pretend network failure');
    }
    final memberships = seedMemberships[personaId] ?? const <Membership>[];
    return [
      for (final m in memberships)
        if (seedStokvels[m.stokvelId] case final stokvel?)
          if (seedFigures[personaId]?[m.stokvelId] case final f?)
            HomeEntry(
              stokvelId: m.stokvelId,
              name: stokvel.name,
              role: m.role,
              paid: f.paid,
              owed: f.owed,
              arrears: f.arrears,
              nextPayout: f.nextPayout,
            ),
    ];
  }
}
