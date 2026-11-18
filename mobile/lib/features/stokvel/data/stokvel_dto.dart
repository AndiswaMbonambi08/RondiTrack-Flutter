import 'package:ronditrack/core/network/json_read.dart';

class CycleDto {
  const new({
    required this.id,
    required this.label,
    required this.status,
    required this.dueDate,
  });

  factory fromJson(Map<String, dynamic> json) => CycleDto(
    id: json['id']! as String,
    label: json['label']! as String,
    status: json['status'] as String?,
    dueDate: dateOnly(json['dueDate']),
  );

  final String id;
  final String label;
  final String? status;
  final DateTime? dueDate;
}

class StokvelDetailDto {
  const new({
    required this.id,
    required this.name,
    required this.contributionCents,
    required this.role,
    required this.currentCycle,
  });

  factory fromJson(Map<String, dynamic> json) => StokvelDetailDto(
    id: json['id']! as String,
    name: json['name']! as String,
    contributionCents: (json['contributionCents']! as num).toInt(),
    role: json['role'] as String?,
    currentCycle: json['currentCycle'] == null
        ? null
        : CycleDto.fromJson(json['currentCycle']! as Map<String, dynamic>),
  );

  final String id;
  final String name;
  final int contributionCents;
  final String? role;
  final CycleDto? currentCycle;
}

class HistoryItemDto {
  const new({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.amountCents,
    required this.status,
    required this.cycleId,
  });

  factory fromJson(Map<String, dynamic> json) => HistoryItemDto(
    id: json['id']! as String,
    memberId: json['memberId']! as String,
    memberName: json['memberName']! as String,
    amountCents: (json['amountCents']! as num).toInt(),
    status: json['status'] as String?,
    cycleId: json['cycleId']! as String,
  );

  final String id;
  final String memberId;
  final String memberName;
  final int amountCents;
  final String? status;
  final String cycleId;
}