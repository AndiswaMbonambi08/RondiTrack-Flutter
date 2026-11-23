import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zu.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zu'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'RondiTrack'**
  String get appTitle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'RondiTrack'**
  String get homeTitle;

  /// No description provided for @homeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'You are not in any stokvels yet.'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Ask your treasurer for an invitation, or start a stokvel.'**
  String get homeEmptyHint;

  /// No description provided for @yourRole.
  ///
  /// In en, this message translates to:
  /// **'Your role: {role}'**
  String yourRole(String role);

  /// No description provided for @paidLine.
  ///
  /// In en, this message translates to:
  /// **'Paid: {amount}'**
  String paidLine(String amount);

  /// No description provided for @owedLine.
  ///
  /// In en, this message translates to:
  /// **'Owed: {amount}'**
  String owedLine(String amount);

  /// No description provided for @arrearsLine.
  ///
  /// In en, this message translates to:
  /// **'Arrears: {amount}'**
  String arrearsLine(String amount);

  /// No description provided for @nextPayoutLine.
  ///
  /// In en, this message translates to:
  /// **'Next payout: {date}'**
  String nextPayoutLine(String date);

  /// No description provided for @nextPayoutNone.
  ///
  /// In en, this message translates to:
  /// **'Next payout: none scheduled'**
  String get nextPayoutNone;

  /// No description provided for @roleMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get roleMember;

  /// No description provided for @roleTreasurer.
  ///
  /// In en, this message translates to:
  /// **'Treasurer'**
  String get roleTreasurer;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @roleUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get roleUnknown;

  /// No description provided for @contributionPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get contributionPending;

  /// No description provided for @contributionPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get contributionPaid;

  /// No description provided for @contributionConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get contributionConfirmed;

  /// No description provided for @contributionUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get contributionUnknown;

  /// No description provided for @cycleOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get cycleOpen;

  /// No description provided for @cycleClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get cycleClosed;

  /// No description provided for @cyclePaidOut.
  ///
  /// In en, this message translates to:
  /// **'Paid out'**
  String get cyclePaidOut;

  /// No description provided for @cycleUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get cycleUnknown;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @closeLabel.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeLabel;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @bannerOffline.
  ///
  /// In en, this message translates to:
  /// **'You are offline'**
  String get bannerOffline;

  /// No description provided for @bannerRefreshFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not refresh'**
  String get bannerRefreshFailed;

  /// No description provided for @bannerUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated {age}'**
  String bannerUpdated(String age);

  /// No description provided for @ageJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get ageJustNow;

  /// No description provided for @ageMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 minute ago} other{{count} minutes ago}}'**
  String ageMinutes(int count);

  /// No description provided for @ageHours.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 hour ago} other{{count} hours ago}}'**
  String ageHours(int count);

  /// No description provided for @ageDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 day ago} other{{count} days ago}}'**
  String ageDays(int count);

  /// No description provided for @stokvelTitle.
  ///
  /// In en, this message translates to:
  /// **'Stokvel'**
  String get stokvelTitle;

  /// No description provided for @stokvelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Stokvels'**
  String get stokvelsTitle;

  /// No description provided for @selectStokvel.
  ///
  /// In en, this message translates to:
  /// **'Select a stokvel'**
  String get selectStokvel;

  /// No description provided for @switchStokvel.
  ///
  /// In en, this message translates to:
  /// **'Switch stokvel'**
  String get switchStokvel;

  /// No description provided for @stokvelNotFound.
  ///
  /// In en, this message translates to:
  /// **'Stokvel not found'**
  String get stokvelNotFound;

  /// No description provided for @cycleTitle.
  ///
  /// In en, this message translates to:
  /// **'Cycle'**
  String get cycleTitle;

  /// No description provided for @cycleNotFound.
  ///
  /// In en, this message translates to:
  /// **'Cycle not found'**
  String get cycleNotFound;

  /// No description provided for @cycleLine.
  ///
  /// In en, this message translates to:
  /// **'Cycle {number}, due {date}'**
  String cycleLine(int number, String date);

  /// No description provided for @viewCycle.
  ///
  /// In en, this message translates to:
  /// **'View cycle'**
  String get viewCycle;

  /// No description provided for @rotationAndPayouts.
  ///
  /// In en, this message translates to:
  /// **'Rotation and payouts'**
  String get rotationAndPayouts;

  /// No description provided for @actionPay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get actionPay;

  /// No description provided for @actionUploadProof.
  ///
  /// In en, this message translates to:
  /// **'Upload proof'**
  String get actionUploadProof;

  /// No description provided for @actionConfirmContributions.
  ///
  /// In en, this message translates to:
  /// **'Confirm contributions'**
  String get actionConfirmContributions;

  /// No description provided for @actionCloseCycle.
  ///
  /// In en, this message translates to:
  /// **'Close cycle'**
  String get actionCloseCycle;

  /// No description provided for @actionRecordPayout.
  ///
  /// In en, this message translates to:
  /// **'Record payout'**
  String get actionRecordPayout;

  /// No description provided for @payoutsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payouts'**
  String get payoutsTitle;

  /// No description provided for @payoutsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No payout order for this cycle yet.'**
  String get payoutsEmptyTitle;

  /// No description provided for @payoutsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'It appears here once your treasurer starts the rotation.'**
  String get payoutsEmptyHint;

  /// No description provided for @payoutNext.
  ///
  /// In en, this message translates to:
  /// **'Next: {name}'**
  String payoutNext(String name);

  /// No description provided for @payoutPositionLine.
  ///
  /// In en, this message translates to:
  /// **'{position}. {name}'**
  String payoutPositionLine(String position, String name);

  /// No description provided for @payoutPaidOn.
  ///
  /// In en, this message translates to:
  /// **'on {date}'**
  String payoutPaidOn(String date);

  /// No description provided for @payoutRecordSoon.
  ///
  /// In en, this message translates to:
  /// **'Recording a payout arrives with the live API.'**
  String get payoutRecordSoon;

  /// No description provided for @noContributions.
  ///
  /// In en, this message translates to:
  /// **'No contributions yet.'**
  String get noContributions;

  /// No description provided for @contributionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No contributions} one{1 contribution} other{{count} contributions}}'**
  String contributionCount(int count);

  /// No description provided for @payTitle.
  ///
  /// In en, this message translates to:
  /// **'Pay contribution'**
  String get payTitle;

  /// No description provided for @payAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount (rands)'**
  String get payAmountLabel;

  /// No description provided for @payAmountHint.
  ///
  /// In en, this message translates to:
  /// **'For example 500 or 500,50'**
  String get payAmountHint;

  /// No description provided for @payButton.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get payButton;

  /// No description provided for @payErrorEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount.'**
  String get payErrorEmpty;

  /// No description provided for @payErrorDecimals.
  ///
  /// In en, this message translates to:
  /// **'Rands have at most two decimals (cents).'**
  String get payErrorDecimals;

  /// No description provided for @payErrorInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount like 500 or 500,50.'**
  String get payErrorInvalid;

  /// No description provided for @payErrorZero.
  ///
  /// In en, this message translates to:
  /// **'The amount must be more than R 0,00.'**
  String get payErrorZero;

  /// No description provided for @payErrorTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The amount can be at most R 1 000 000.'**
  String get payErrorTooLarge;

  /// No description provided for @payPendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Pending: {amount}'**
  String payPendingLabel(String amount);

  /// No description provided for @payNotSent.
  ///
  /// In en, this message translates to:
  /// **'Not sent yet. It will be sent when you try again, and it cannot be paid twice.'**
  String get payNotSent;

  /// No description provided for @payWaiting.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Waiting 1 second before trying again.} other{Waiting {count} seconds before trying again.}}'**
  String payWaiting(int count);

  /// No description provided for @payExpired.
  ///
  /// In en, this message translates to:
  /// **'This payment was never sent and is too old to send now. Check your contributions and pay again if you still need to.'**
  String get payExpired;

  /// No description provided for @payRefusedClosed.
  ///
  /// In en, this message translates to:
  /// **'This cycle is closed, so payments can no longer be recorded for it.'**
  String get payRefusedClosed;

  /// No description provided for @payRefusedPaidOut.
  ///
  /// In en, this message translates to:
  /// **'This cycle has already been paid out.'**
  String get payRefusedPaidOut;

  /// No description provided for @payPaidSnack.
  ///
  /// In en, this message translates to:
  /// **'Paid. Your totals are being updated.'**
  String get payPaidSnack;

  /// No description provided for @profileSignedIn.
  ///
  /// In en, this message translates to:
  /// **'You are signed in.'**
  String get profileSignedIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutTitle;

  /// No description provided for @signOutOutboxWarning.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{You have 1 payment that has not been sent. Signing out deletes it.} other{You have {count} payments that have not been sent. Signing out deletes them.}}'**
  String signOutOutboxWarning(int count);

  /// No description provided for @signOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Sign out anyway'**
  String get signOutConfirm;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow my phone'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageZulu.
  ///
  /// In en, this message translates to:
  /// **'isiZulu'**
  String get languageZulu;

  /// No description provided for @failValidation.
  ///
  /// In en, this message translates to:
  /// **'Please check what you entered and try again.'**
  String get failValidation;

  /// No description provided for @failUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again.'**
  String get failUnauthorized;

  /// No description provided for @failForbidden.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to do that.'**
  String get failForbidden;

  /// No description provided for @failNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get failNotFound;

  /// No description provided for @failStale.
  ///
  /// In en, this message translates to:
  /// **'This changed elsewhere. Refresh and try again.'**
  String get failStale;

  /// No description provided for @failConflict.
  ///
  /// In en, this message translates to:
  /// **'That conflicts with the current state. Refresh and try again.'**
  String get failConflict;

  /// No description provided for @failRule.
  ///
  /// In en, this message translates to:
  /// **'That is not allowed right now.'**
  String get failRule;

  /// No description provided for @failRateLimitedShort.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please wait a moment and try again.'**
  String get failRateLimitedShort;

  /// No description provided for @failRateLimited.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Too many requests. Try again in 1 second.} other{Too many requests. Try again in {count} seconds.}}'**
  String failRateLimited(int count);

  /// No description provided for @failServer.
  ///
  /// In en, this message translates to:
  /// **'Sorry, something went wrong on our side.'**
  String get failServer;

  /// No description provided for @failNoAnswer.
  ///
  /// In en, this message translates to:
  /// **'You are offline, or we could not reach the server.'**
  String get failNoAnswer;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zu'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zu':
      return AppLocalizationsZu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
