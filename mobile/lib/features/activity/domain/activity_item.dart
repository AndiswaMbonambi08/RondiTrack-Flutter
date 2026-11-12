import 'package:ronditrack/features/stokvel/domain/enums.dart';

class ActivityItem {
  const new({
    required this.id,
    required this.stokvelName,
    required this.memberName,
    required this.status,
  });

  final String id;
  final String stokvelName;
  final String memberName;
  final ContributionStatus status;
}
