import 'package:ronditrack/core/network/json_read.dart';

class ActivityItemDto {
  const new({
    required this.id,
    required this.kind,
    required this.stokvelId,
    required this.stokvelName,
    required this.occurredAt,
    required this.actorName,
    required this.amountCents,
  });

  factory fromJson(Map<String, dynamic> json) => ActivityItemDto(
    id: json['id']! as String,
    kind: json['kind']! as String,
    stokvelId: json['stokvelId']! as String,
    stokvelName: json['stokvelName']! as String,
    occurredAt: utcInstant(json['occurredAt'])!,
    actorName: json['actorName'] as String?,
    amountCents: (json['amountCents'] as num?)?.toInt(),
  );

  final String id;

  /// Contribution, Payout or MemberJoined.
  final String kind;
  final String stokvelId;
  final String stokvelName;
  final DateTime occurredAt;

  /// Null unless the caller is a Treasurer or Admin there, or the actor.
  final String? actorName;

  /// Null for MemberJoined.
  final int? amountCents;
}

class ActivityPageDto {
  const new({required this.items, required this.nextPageToken});

  factory fromJson(Map<String, dynamic> json) => ActivityPageDto(
    items: [
      for (final i in json['items']! as List<dynamic>)
        ActivityItemDto.fromJson(i! as Map<String, dynamic>),
    ],
    nextPageToken: json['nextPageToken'] as String?,
  );

  final List<ActivityItemDto> items;

  /// How a page ends is Contract note 1. It stays raw here and becomes
  /// "no more pages" in the mapper once the real answer is recorded.
  final String? nextPageToken;
}
