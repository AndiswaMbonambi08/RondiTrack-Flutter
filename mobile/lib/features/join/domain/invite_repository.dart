import 'package:ronditrack/features/join/domain/invite.dart';

abstract interface class InviteRepository {
  /// Null when the code is not a real invitation.
  Future<Invite?> preview(String code);
}
