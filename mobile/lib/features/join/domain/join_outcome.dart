sealed class JoinOutcome {
  const new();
}

final class Joined extends JoinOutcome {
  const new(this.stokvelId);

  final String stokvelId;
}

final class AlreadyMember extends JoinOutcome {
  const new(this.stokvelId);

  final String? stokvelId;
}

/// 404 (unknown code) or 410 (expired code).
final class InvalidInvite extends JoinOutcome {
  const new();
}

final class JoinFailed extends JoinOutcome {
  const new();
}
