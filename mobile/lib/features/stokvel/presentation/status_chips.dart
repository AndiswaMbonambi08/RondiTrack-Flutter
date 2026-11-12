import 'package:flutter/material.dart';
import 'package:ronditrack/core/status_chip.dart';
import 'package:ronditrack/core/theme/status_colors.dart';
import 'package:ronditrack/features/stokvel/domain/enums.dart';
import 'package:ronditrack/features/stokvel/presentation/labels.dart';

/// No wildcard over a status: a new status is a compile error here.
class ContributionStatusChip extends StatelessWidget {
  const new({required this.status, super.key});

  final ContributionStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.statusColors;
    final (style, icon) = switch (status) {
      ContributionStatus.pending => (colors.pending, Icons.schedule),
      ContributionStatus.paid => (colors.paid, Icons.hourglass_top),
      ContributionStatus.confirmed => (colors.confirmed, Icons.check_circle),
      ContributionStatus.unknown => (colors.unknown, Icons.help_outline),
    };
    return StatusChip(
      label: contributionLabel(status),
      icon: icon,
      style: style,
    );
  }
}

class CycleStatusChip extends StatelessWidget {
  const new({required this.status, super.key});

  final CycleStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.statusColors;
    final (style, icon) = switch (status) {
      CycleStatus.open => (colors.open, Icons.lock_open),
      CycleStatus.closed => (colors.closed, Icons.lock),
      CycleStatus.paidOut => (colors.paidOut, Icons.payments),
      CycleStatus.unknown => (colors.unknown, Icons.help_outline),
    };
    return StatusChip(label: cycleLabel(status), icon: icon, style: style);
  }
}
