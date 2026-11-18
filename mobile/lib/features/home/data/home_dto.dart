import 'package:ronditrack/core/network/json_read.dart';

class HomeStokvelDto {
  const new({
    required this.stokvelId,
    required this.name,
    required this.role,
    required this.paidCents,
    required this.owedCents,
    required this.arrearsCents,
    required this.nextPayoutUtc,
  });

  factory fromJson(Map<String, dynamic> json) => HomeStokvelDto(
    stokvelId: json['stokvelId']! as String,
    name: json['name']! as String,
    role: json['role'] as String?,
    paidCents: (json['paidCents']! as num).toInt(),
    owedCents: (json['owedCents']! as num).toInt(),
    arrearsCents: (json['arrearsCents']! as num).toInt(),
    nextPayoutUtc: utcInstant(json['nextPayoutUtc']),
  );

  final String stokvelId;
  final String name;
  final String? role;
  final int paidCents;
  final int owedCents;
  final int arrearsCents;
  final DateTime? nextPayoutUtc;
}

class HomeDto {
  const new({required this.stokvels});

  factory fromJson(Map<String, dynamic> json) => HomeDto(
    stokvels: [
      for (final s in json['stokvels']! as List<dynamic>)
        HomeStokvelDto.fromJson(s! as Map<String, dynamic>),
    ],
  );

  final List<HomeStokvelDto> stokvels;
}