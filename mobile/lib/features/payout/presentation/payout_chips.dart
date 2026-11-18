import 'package:flutter/material.dart';
import 'package:ronditrack/core/status_chip.dart';
import 'package:ronditrack/core/theme/status_colors.dart';
import 'package:ronditrack/features/payout/domain/payout_status.dart';
import 'package:ronditrack/features/payout/presentation/payout_labels.dart';

/// No wildcard over a status: a new status is a compile error here. Words,
/// an icon and a colour, never colour alone.
class PayoutStatusChip extends StatelessWidget {
  const new({required this.status, super.key});

  final PayoutStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.statusColors;
    final (style, icon) = switch (status) {
      PayoutStatus.paid => (colors.paidOut, Icons.payments),
      PayoutStatus.next => (colors.next, Icons.arrow_forward),
      PayoutStatus.waiting => (colors.pending, Icons.schedule),
      PayoutStatus.unknown => (colors.unknown, Icons.help_outline),
    };
    return StatusChip(
      label: payoutStatusLabel(status),
      icon: icon,
      style: style,
    );
  }
}
