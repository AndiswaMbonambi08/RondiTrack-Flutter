import 'package:flutter/material.dart';
import 'package:ronditrack/core/money/money_format.dart';
import 'package:ronditrack/features/stokvel/domain/models.dart';
import 'package:ronditrack/l10n/generated/app_localizations.dart';
import 'package:ronditrack/l10n/labels.dart';

/// One contribution. The status is icon and words, never colour alone.
class ContributionLine extends StatelessWidget {
  const new({required this.contribution, super.key});

  final Contribution contribution;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ExcludeSemantics(
        child: Icon(contributionStatusIcon(contribution.status)),
      ),
      title: Text(contribution.memberName),
      subtitle: Text(contributionStatusText(l, contribution.status)),
      trailing: Text(formatRands(contribution.amount)),
    );
  }
}