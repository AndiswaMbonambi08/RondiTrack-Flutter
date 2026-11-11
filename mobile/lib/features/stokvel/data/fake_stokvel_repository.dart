import 'package:ronditrack/core/errors.dart';
import 'package:ronditrack/features/stokvel/data/pretend_network.dart';
import 'package:ronditrack/features/stokvel/data/seed.dart';
import 'package:ronditrack/features/stokvel/domain/models.dart';
import 'package:ronditrack/features/stokvel/domain/stokvel_repository.dart';

class FakeStokvelRepository implements StokvelRepository {
  /// [delayScale] 0 removes the pretend network delay (tests).
  new({required this.personaId, this.delayScale = 1});

  final String personaId;
  final double delayScale;

  @override
  Future<StokvelDetail> fetchDetail(String id) async {
    await pretendNetwork(seedDelaysMs[id] ?? 300, delayScale);
    final membership = (seedMemberships[personaId] ?? const <Membership>[])
        .where((m) => m.stokvelId == id)
        .firstOrNull;
    final stokvel = seedStokvels[id];
    if (membership == null || stokvel == null) throw const NotFoundException();
    final contributions = seedContributions[id] ?? const <Contribution>[];
    return StokvelDetail(
      stokvel: stokvel,
      role: membership.role,
      cycle: seedCycles[id],
      contributions: contributions,
      myContribution: contributions
          .where((c) => c.memberId == personaId)
          .firstOrNull
          ?.status,
    );
  }
}
