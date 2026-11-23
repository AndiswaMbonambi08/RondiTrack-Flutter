import 'package:flutter/material.dart';
import 'package:ronditrack/core/failure/failure.dart';
import 'package:ronditrack/features/stokvel/domain/enums.dart';
import 'package:ronditrack/l10n/generated/app_localizations.dart';

String roleText(AppLocalizations l, StokvelRole role) => switch (role) {
  StokvelRole.member => l.roleMember,
  StokvelRole.treasurer => l.roleTreasurer,
  StokvelRole.admin => l.roleAdmin,
  StokvelRole.unknown => l.roleUnknown,
};

String contributionStatusText(AppLocalizations l, ContributionStatus s) =>
    switch (s) {
      ContributionStatus.pending => l.contributionPending,
      ContributionStatus.paid => l.contributionPaid,
      ContributionStatus.confirmed => l.contributionConfirmed,
      ContributionStatus.unknown => l.contributionUnknown,
    };

/// Every status has an icon AND words, never a colour alone.
IconData contributionStatusIcon(ContributionStatus s) => switch (s) {
  ContributionStatus.pending => Icons.schedule,
  ContributionStatus.paid => Icons.check_circle_outline,
  ContributionStatus.confirmed => Icons.verified_outlined,
  ContributionStatus.unknown => Icons.help_outline,
};

String cycleStatusText(AppLocalizations l, CycleStatus s) => switch (s) {
  CycleStatus.open => l.cycleOpen,
  CycleStatus.closed => l.cycleClosed,
  CycleStatus.paidOut => l.cyclePaidOut,
  CycleStatus.unknown => l.cycleUnknown,
};

IconData cycleStatusIcon(CycleStatus s) => switch (s) {
  CycleStatus.open => Icons.lock_open,
  CycleStatus.closed => Icons.lock_outline,
  CycleStatus.paidOut => Icons.payments_outlined,
  CycleStatus.unknown => Icons.help_outline,
};

String failureText(AppLocalizations l, Failure f) => switch (f) {
  ValidationFailure() => l.failValidation,
  UnauthorizedFailure() => l.failUnauthorized,
  ForbiddenFailure() => l.failForbidden,
  NotFoundFailure() => l.failNotFound,
  ConflictFailure(isStale: true) => l.failStale,
  ConflictFailure() => l.failConflict,
  RuleFailure() => l.failRule,
  RateLimitedFailure(:final retryAfterSeconds) =>
    retryAfterSeconds == null
        ? l.failRateLimitedShort
        : l.failRateLimited(retryAfterSeconds),
  ServerFailure() => l.failServer,
  NoAnswerFailure() => l.failNoAnswer,
};

/// How old cached data is, in words.
String ageText(AppLocalizations l, Duration age) {
  if (age.inMinutes < 1) return l.ageJustNow;
  if (age.inHours < 1) return l.ageMinutes(age.inMinutes);
  if (age.inDays < 1) return l.ageHours(age.inHours);
  return l.ageDays(age.inDays);
}