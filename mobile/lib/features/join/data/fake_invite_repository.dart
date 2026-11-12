import 'package:ronditrack/features/join/domain/invite.dart';
import 'package:ronditrack/features/join/domain/invite_repository.dart';
import 'package:ronditrack/features/stokvel/data/pretend_network.dart';
import 'package:ronditrack/features/stokvel/data/seed.dart';
import 'package:ronditrack/features/stokvel/domain/models.dart';

// Fake invitation codes (made-up data).
const _invites = <String, String>{
  'ubuntu2026': 'ubuntu-savings-circle',
  'umoja2026': 'umoja-family-fund',
};

class FakeInviteRepository implements InviteRepository {
  new({required this.personaId, this.delayScale = 1});

  final String personaId;
  final double delayScale;

  @override
  Future<Invite?> preview(String code) async {
    await pretendNetwork(300, delayScale);
    final stokvelId = _invites[code.toLowerCase()];
    final stokvel = stokvelId == null ? null : seedStokvels[stokvelId];
    if (stokvelId == null || stokvel == null) return null;
    final memberships = seedMemberships[personaId] ?? const <Membership>[];
    return Invite(
      code: code,
      stokvelId: stokvelId,
      stokvelName: stokvel.name,
      contribution: stokvel.contributionAmount,
      alreadyMember: memberships.any((m) => m.stokvelId == stokvelId),
    );
  }
}
