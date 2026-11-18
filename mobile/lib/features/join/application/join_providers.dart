import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ronditrack/core/network/api_mode.dart';
import 'package:ronditrack/core/network/dev_session.dart';
import 'package:ronditrack/core/network/dio_provider.dart';
import 'package:ronditrack/core/session/session.dart';
import 'package:ronditrack/features/join/data/api_invite_repository.dart';
import 'package:ronditrack/features/join/data/fake_invite_repository.dart';
import 'package:ronditrack/features/join/domain/invite.dart';
import 'package:ronditrack/features/join/domain/invite_repository.dart';

part 'join_providers.g.dart';

/// The only place that names the implementation: fakes or the API.
@Riverpod(keepAlive: true)
InviteRepository inviteRepository(Ref ref) {
  if (ref.watch(useFakesProvider)) {
    return FakeInviteRepository(personaId: ref.watch(currentPersonaProvider));
  }
  return ApiInviteRepository(
    ref.watch(dioProvider),
    ref.watch(devSessionProvider),
  );
}

@riverpod
Future<Invite?> invitePreview(Ref ref, String code) =>
    ref.watch(inviteRepositoryProvider).preview(code);
