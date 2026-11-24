/// Analytics carries ids only: never a name, email, phone number or amount.
abstract class AnalyticsEvents {
  void contributionRecorded({
    required String stokvelId,
    required String memberId,
  });
  void stokvelOpened({required String stokvelId});
  void signedOut();
}

class NoopAnalytics implements AnalyticsEvents {
  const NoopAnalytics();
  @override
  void contributionRecorded({
    required String stokvelId,
    required String memberId,
  }) {}
  @override
  void stokvelOpened({required String stokvelId}) {}
  @override
  void signedOut() {}
}

/// For tests: records every event and its fields.
class RecordingAnalytics implements AnalyticsEvents {
  final events = <({String name, Map<String, String> fields})>[];
  @override
  void contributionRecorded({
    required String stokvelId,
    required String memberId,
  }) => events.add((
    name: 'contribution_recorded',
    fields: {'stokvel_id': stokvelId, 'member_id': memberId},
  ));
  @override
  void stokvelOpened({required String stokvelId}) =>
      events.add((name: 'stokvel_opened', fields: {'stokvel_id': stokvelId}));
  @override
  void signedOut() => events.add((name: 'signed_out', fields: {}));
}
