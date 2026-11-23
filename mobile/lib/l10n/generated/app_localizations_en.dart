// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'RondiTrack';

  @override
  String get homeTitle => 'RondiTrack';

  @override
  String get homeEmptyTitle => 'You are not in any stokvels yet.';

  @override
  String get homeEmptyHint =>
      'Ask your treasurer for an invitation, or start a stokvel.';

  @override
  String yourRole(String role) {
    return 'Your role: $role';
  }

  @override
  String paidLine(String amount) {
    return 'Paid: $amount';
  }

  @override
  String owedLine(String amount) {
    return 'Owed: $amount';
  }

  @override
  String arrearsLine(String amount) {
    return 'Arrears: $amount';
  }

  @override
  String nextPayoutLine(String date) {
    return 'Next payout: $date';
  }

  @override
  String get nextPayoutNone => 'Next payout: none scheduled';

  @override
  String get roleMember => 'Member';

  @override
  String get roleTreasurer => 'Treasurer';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleUnknown => 'Unknown';

  @override
  String get contributionPending => 'Pending';

  @override
  String get contributionPaid => 'Paid';

  @override
  String get contributionConfirmed => 'Confirmed';

  @override
  String get contributionUnknown => 'Unknown';

  @override
  String get cycleOpen => 'Open';

  @override
  String get cycleClosed => 'Closed';

  @override
  String get cyclePaidOut => 'Paid out';

  @override
  String get cycleUnknown => 'Unknown';

  @override
  String get tryAgain => 'Try again';

  @override
  String get closeLabel => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get bannerOffline => 'You are offline';

  @override
  String get bannerRefreshFailed => 'Could not refresh';

  @override
  String bannerUpdated(String age) {
    return 'Last updated $age';
  }

  @override
  String get ageJustNow => 'just now';

  @override
  String ageMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String ageHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String ageDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get stokvelTitle => 'Stokvel';

  @override
  String get stokvelsTitle => 'Stokvels';

  @override
  String get selectStokvel => 'Select a stokvel';

  @override
  String get switchStokvel => 'Switch stokvel';

  @override
  String get stokvelNotFound => 'Stokvel not found';

  @override
  String get cycleTitle => 'Cycle';

  @override
  String get cycleNotFound => 'Cycle not found';

  @override
  String cycleLine(int number, String date) {
    return 'Cycle $number, due $date';
  }

  @override
  String get viewCycle => 'View cycle';

  @override
  String get rotationAndPayouts => 'Rotation and payouts';

  @override
  String get actionPay => 'Pay';

  @override
  String get actionUploadProof => 'Upload proof';

  @override
  String get actionConfirmContributions => 'Confirm contributions';

  @override
  String get actionCloseCycle => 'Close cycle';

  @override
  String get actionRecordPayout => 'Record payout';

  @override
  String get payoutsTitle => 'Payouts';

  @override
  String get payoutsEmptyTitle => 'No payout order for this cycle yet.';

  @override
  String get payoutsEmptyHint =>
      'It appears here once your treasurer starts the rotation.';

  @override
  String payoutNext(String name) {
    return 'Next: $name';
  }

  @override
  String payoutPositionLine(String position, String name) {
    return '$position. $name';
  }

  @override
  String payoutPaidOn(String date) {
    return 'on $date';
  }

  @override
  String get payoutRecordSoon =>
      'Recording a payout arrives with the live API.';

  @override
  String get noContributions => 'No contributions yet.';

  @override
  String contributionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contributions',
      one: '1 contribution',
      zero: 'No contributions',
    );
    return '$_temp0';
  }

  @override
  String get payTitle => 'Pay contribution';

  @override
  String get payAmountLabel => 'Amount (rands)';

  @override
  String get payAmountHint => 'For example 500 or 500,50';

  @override
  String get payButton => 'Pay';

  @override
  String get payErrorEmpty => 'Enter an amount.';

  @override
  String get payErrorDecimals => 'Rands have at most two decimals (cents).';

  @override
  String get payErrorInvalid => 'Enter an amount like 500 or 500,50.';

  @override
  String get payErrorZero => 'The amount must be more than R 0,00.';

  @override
  String get payErrorTooLarge => 'The amount can be at most R 1 000 000.';

  @override
  String payPendingLabel(String amount) {
    return 'Pending: $amount';
  }

  @override
  String get payNotSent =>
      'Not sent yet. It will be sent when you try again, and it cannot be paid twice.';

  @override
  String payWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Waiting $count seconds before trying again.',
      one: 'Waiting 1 second before trying again.',
    );
    return '$_temp0';
  }

  @override
  String get payExpired =>
      'This payment was never sent and is too old to send now. Check your contributions and pay again if you still need to.';

  @override
  String get payRefusedClosed =>
      'This cycle is closed, so payments can no longer be recorded for it.';

  @override
  String get payRefusedPaidOut => 'This cycle has already been paid out.';

  @override
  String get payPaidSnack => 'Paid. Your totals are being updated.';

  @override
  String get profileSignedIn => 'You are signed in.';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutTitle => 'Sign out?';

  @override
  String signOutOutboxWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'You have $count payments that have not been sent. Signing out deletes them.',
      one: 'You have 1 payment that has not been sent. Signing out deletes it.',
    );
    return '$_temp0';
  }

  @override
  String get signOutConfirm => 'Sign out anyway';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSystem => 'Follow my phone';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageZulu => 'isiZulu';

  @override
  String get failValidation => 'Please check what you entered and try again.';

  @override
  String get failUnauthorized => 'Please sign in again.';

  @override
  String get failForbidden => 'You do not have permission to do that.';

  @override
  String get failNotFound => 'Not found';

  @override
  String get failStale => 'This changed elsewhere. Refresh and try again.';

  @override
  String get failConflict =>
      'That conflicts with the current state. Refresh and try again.';

  @override
  String get failRule => 'That is not allowed right now.';

  @override
  String get failRateLimitedShort =>
      'Too many requests. Please wait a moment and try again.';

  @override
  String failRateLimited(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Too many requests. Try again in $count seconds.',
      one: 'Too many requests. Try again in 1 second.',
    );
    return '$_temp0';
  }

  @override
  String get failServer => 'Sorry, something went wrong on our side.';

  @override
  String get failNoAnswer =>
      'You are offline, or we could not reach the server.';
}
