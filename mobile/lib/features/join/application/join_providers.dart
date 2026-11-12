import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ronditrack/core/session/session.dart';
import 'package:ronditrack/features/join/data/fake_invite_repository.dart';
import 'package:ronditrack/features/join/domain/invite.dart';
import 'package:ronditrack/features/join/domain/invite_repository.dart';

part 'join_providers.g.dart';

/// The only line Week 11 changes: names the implementation.
@Riverpod(keepAlive: true)
InviteRepository inviteRepository(Ref ref) =>
    FakeInviteRepository(personaId: ref.watch(currentPersonaProvider));

@riverpod
Future<Invite?> invitePreview(Ref ref, String code) =>
    ref.watch(inviteRepositoryProvider).preview(code);
