import 'package:ronditrack/core/money/cents.dart';

class Invite {
  const new({
    required this.code,
    required this.stokvelId,
    required this.stokvelName,
    required this.contribution,
    required this.alreadyMember,
  });

  final String code;
  final String stokvelId;
  final String stokvelName;
  final Cents contribution;
  final bool alreadyMember;
}
