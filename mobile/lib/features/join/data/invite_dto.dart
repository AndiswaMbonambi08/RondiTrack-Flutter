class InvitePreviewDto {
  const new({
    required this.stokvelName,
    required this.contributionCents,
    required this.alreadyMember,
    required this.stokvelId,
  });

  factory fromJson(Map<String, dynamic> json) => InvitePreviewDto(
    stokvelName: json['stokvelName']! as String,
    contributionCents: (json['contributionCents']! as num).toInt(),
    alreadyMember: json['alreadyMember']! as bool,
    stokvelId: json['stokvelId'] as String?,
  );

  final String stokvelName;
  final int contributionCents;
  final bool alreadyMember;

  /// The API only sends this when the caller is already a member.
  final String? stokvelId;
}
