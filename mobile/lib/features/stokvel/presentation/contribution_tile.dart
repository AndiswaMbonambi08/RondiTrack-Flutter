import 'package:flutter/material.dart';
import 'package:ronditrack/core/money/money_format.dart';
import 'package:ronditrack/features/stokvel/domain/models.dart';
import 'package:ronditrack/features/stokvel/presentation/status_chips.dart';

class ContributionTile extends StatelessWidget {
  const new({required this.contribution, super.key});

  final Contribution contribution;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(contribution.memberName),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: ContributionStatusChip(status: contribution.status),
        ),
      ),
      trailing: Text(formatRands(contribution.amount)),
    );
  }
}
