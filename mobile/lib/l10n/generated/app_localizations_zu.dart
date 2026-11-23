// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Zulu (`zu`).
class AppLocalizationsZu extends AppLocalizations {
  AppLocalizationsZu([String locale = 'zu']) : super(locale);

  @override
  String get appTitle => 'RondiTrack';

  @override
  String get homeTitle => 'RondiTrack';

  @override
  String get homeEmptyTitle => 'Awukho kunoma iyiphi i-stokvel okwamanje.';

  @override
  String get homeEmptyHint =>
      'Cela isimemo komgcini wezimali wakho, noma uqale i-stokvel.';

  @override
  String yourRole(String role) {
    return 'Indima yakho: $role';
  }

  @override
  String paidLine(String amount) {
    return 'Okukhokhiwe: $amount';
  }

  @override
  String owedLine(String amount) {
    return 'Okukweletwayo: $amount';
  }

  @override
  String arrearsLine(String amount) {
    return 'Izinsalela: $amount';
  }

  @override
  String nextPayoutLine(String date) {
    return 'Ukukhokhelwa okulandelayo: $date';
  }

  @override
  String get nextPayoutNone => 'Ukukhokhelwa okulandelayo: akukamiswa';

  @override
  String get roleMember => 'Ilungu';

  @override
  String get roleTreasurer => 'Umgcini wezimali';

  @override
  String get roleAdmin => 'Umphathi';

  @override
  String get roleUnknown => 'Akwaziwa';

  @override
  String get contributionPending => 'Kuyalindwa';

  @override
  String get contributionPaid => 'Kukhokhiwe';

  @override
  String get contributionConfirmed => 'Kuqinisekisiwe';

  @override
  String get contributionUnknown => 'Akwaziwa';

  @override
  String get cycleOpen => 'Vuliwe';

  @override
  String get cycleClosed => 'Kuvaliwe';

  @override
  String get cyclePaidOut => 'Kukhokhelwe';

  @override
  String get cycleUnknown => 'Akwaziwa';

  @override
  String get tryAgain => 'Zama futhi';

  @override
  String get closeLabel => 'Vala';

  @override
  String get cancel => 'Khansela';

  @override
  String get bannerOffline => 'Awunalo uxhumano';

  @override
  String get bannerRefreshFailed => 'Ayikwazanga ukuvuselela';

  @override
  String bannerUpdated(String age) {
    return 'Kuvuselelwe $age';
  }

  @override
  String get ageJustNow => 'khona manje';

  @override
  String ageMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ngemizuzu engu-$count edlule',
      one: 'ngomzuzu o-1 odlule',
    );
    return '$_temp0';
  }

  @override
  String ageHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ngamahora angu-$count adlule',
      one: 'ngehora eli-1 elidlule',
    );
    return '$_temp0';
  }

  @override
  String ageDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ngezinsuku ezingu-$count ezedlule',
      one: 'ngosuku olu-1 olwedlule',
    );
    return '$_temp0';
  }

  @override
  String get stokvelTitle => 'I-stokvel';

  @override
  String get stokvelsTitle => 'Ama-stokvel';

  @override
  String get selectStokvel => 'Khetha i-stokvel';

  @override
  String get switchStokvel => 'Shintsha i-stokvel';

  @override
  String get stokvelNotFound => 'I-stokvel ayitholakalanga';

  @override
  String get cycleTitle => 'Umjikelezo';

  @override
  String get cycleNotFound => 'Umjikelezo awutholakalanga';

  @override
  String cycleLine(int number, String date) {
    return 'Umjikelezo $number, kumele ukhokhwe ngo-$date';
  }

  @override
  String get viewCycle => 'Buka umjikelezo';

  @override
  String get rotationAndPayouts => 'Ukujikeleza nezinkokhelo';

  @override
  String get actionPay => 'Khokha';

  @override
  String get actionUploadProof => 'Layisha ubufakazi';

  @override
  String get actionConfirmContributions => 'Qinisekisa iminikelo';

  @override
  String get actionCloseCycle => 'Vala umjikelezo';

  @override
  String get actionRecordPayout => 'Qopha inkokhelo';

  @override
  String get payoutsTitle => 'Izinkokhelo';

  @override
  String get payoutsEmptyTitle =>
      'Akukabikho ukuhleleka kwezinkokhelo kulo mjikelezo.';

  @override
  String get payoutsEmptyHint =>
      'Kuzovela lapha uma umgcini wezimali wakho eqala ukujikeleza.';

  @override
  String payoutNext(String name) {
    return 'Olandelayo: $name';
  }

  @override
  String payoutPositionLine(String position, String name) {
    return '$position. $name';
  }

  @override
  String payoutPaidOn(String date) {
    return 'ngo-$date';
  }

  @override
  String get payoutRecordSoon =>
      'Ukuqopha inkokhelo kuzofika nge-API ebukhoma.';

  @override
  String get noContributions => 'Azikho iminikelo okwamanje.';

  @override
  String contributionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Iminikelo engu-$count',
      one: 'Umnikelo o-1',
      zero: 'Azikho iminikelo',
    );
    return '$_temp0';
  }

  @override
  String get payTitle => 'Khokha umnikelo';

  @override
  String get payAmountLabel => 'Inani (ama-rand)';

  @override
  String get payAmountHint => 'Isibonelo 500 noma 500,50';

  @override
  String get payButton => 'Khokha';

  @override
  String get payErrorEmpty => 'Faka inani.';

  @override
  String get payErrorDecimals =>
      'Ama-rand anezindawo ezimbili kuphela zamasenti.';

  @override
  String get payErrorInvalid => 'Faka inani elinjengo-500 noma 500,50.';

  @override
  String get payErrorZero => 'Inani kumele libe ngaphezu kuka-R 0,00.';

  @override
  String get payErrorTooLarge => 'Inani lingaba ngu-R 1 000 000 ubuningi.';

  @override
  String payPendingLabel(String amount) {
    return 'Kuyalindwa: $amount';
  }

  @override
  String get payNotSent =>
      'Ayikathunyelwa. Izothunyelwa uma uzama futhi, futhi ayikwazi ukukhokhwa kabili.';

  @override
  String payWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kulindwe amasekhondi angu-$count ngaphambi kokuzama futhi.',
      one: 'Kulindwe isekhondi eli-1 ngaphambi kokuzama futhi.',
    );
    return '$_temp0';
  }

  @override
  String get payExpired =>
      'Le nkokhelo ayizange ithunyelwe futhi iseyindala kakhulu ukuthi ingathunyelwa manje. Hlola iminikelo yakho bese ukhokha futhi uma kudingeka.';

  @override
  String get payRefusedClosed =>
      'Lo mjikelezo uvaliwe, ngakho iminikelo ayisakwazi ukuqoshwa kuwo.';

  @override
  String get payRefusedPaidOut => 'Lo mjikelezo usuke wakhokhelwa.';

  @override
  String get payPaidSnack => 'Kukhokhiwe. Izibalo zakho ziyabuyekezwa.';

  @override
  String get profileSignedIn => 'Usungenile.';

  @override
  String get signOut => 'Phuma';

  @override
  String get signOutTitle => 'Phuma?';

  @override
  String signOutOutboxWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Unezinkokhelo ezingu-$count ezingakathunyelwa. Ukuphuma kuzisusa.',
      one: 'Unenkokhelo eyodwa engakathunyelwa. Ukuphuma kuyisusa.',
    );
    return '$_temp0';
  }

  @override
  String get signOutConfirm => 'Phuma noma kunjalo';

  @override
  String get splashOfflineTitle => 'Awunalo uxhumano';

  @override
  String get splashOfflineBody =>
      'Usangene. Hlola uxhumano lwakho bese uzama futhi.';

  @override
  String get splashRestoring => 'Kubuyiswa iseshini yakho';

  @override
  String get signInTitle => 'Ngena';

  @override
  String get signInButton => 'Ngena';

  @override
  String get emailLabel => 'I-imeyili';

  @override
  String get passwordLabel => 'Iphasiwedi';

  @override
  String get showPassword => 'Khombisa iphasiwedi';

  @override
  String get hidePassword => 'Fihla iphasiwedi';

  @override
  String get createAccount => 'Dala i-akhawunti';

  @override
  String get signInEnterBoth => 'Faka i-imeyili nephasiwedi yakho.';

  @override
  String get signInWrongCredentials => 'I-imeyili nephasiwedi akufani.';

  @override
  String signInRateLimited(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Imizamo eminingi kakhulu. Ungazama futhi ngemuva kwamasekhondi angu-$count.',
      one:
          'Imizamo eminingi kakhulu. Ungazama futhi ngemuva kwesekhondi eli-1.',
    );
    return '$_temp0';
  }

  @override
  String get signInNetworkDown =>
      'Asikwazanga ukufinyelela i-RondiTrack. Hlola uxhumano lwakho.';

  @override
  String get signInFieldErrors => 'Hlola i-imeyili nephasiwedi yakho.';

  @override
  String get signInGenericError => 'Kukhona okungahambanga kahle. Zama futhi.';

  @override
  String signInWait(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zama futhi ngemuva kwamasekhondi angu-$count',
      one: 'Zama futhi ngemuva kwesekhondi eli-1',
    );
    return '$_temp0';
  }

  @override
  String get signInJoining => 'Ngena ukuze ujoyine i-stokvel obumeniwe kuyo.';

  @override
  String get signInFollowLink => 'Ngena ukuze uvule isixhumanisi osilandele.';

  @override
  String get signInDemoHint =>
      'Ama-akhawunti okuboniswa (idatha eqanjiwe). Bhala iphasiwedi.';

  @override
  String get languageTitle => 'Ulimi';

  @override
  String get languageSystem => 'Landela ifoni yami';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageZulu => 'isiZulu';

  @override
  String get failValidation => 'Sicela uhlole osikufakile bese uzama futhi.';

  @override
  String get failUnauthorized => 'Sicela ungene futhi.';

  @override
  String get failForbidden => 'Awunayo imvume yokwenza lokho.';

  @override
  String get failNotFound => 'Akutholakalanga';

  @override
  String get failStale =>
      'Lokhu kushintshiwe kwenye indawo. Vuselela bese uzama futhi.';

  @override
  String get failConflict =>
      'Lokho akuhambisani nesimo samanje. Vuselela bese uzama futhi.';

  @override
  String get failRule => 'Lokho akuvunyelwe okwamanje.';

  @override
  String get failRateLimitedShort =>
      'Izicelo zimaningi kakhulu. Sicela ulinde isikhashana bese uzama futhi.';

  @override
  String failRateLimited(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Izicelo zimaningi kakhulu. Zama futhi ngemuva kwamasekhondi angu-$count.',
      one: 'Izicelo zimaningi kakhulu. Zama futhi ngemuva kwesekhondi eli-1.',
    );
    return '$_temp0';
  }

  @override
  String get failServer =>
      'Siyaxolisa, kukhona okungahambanga kahle ohlangothini lwethu.';

  @override
  String get failNoAnswer =>
      'Awunalo uxhumano, noma asikwazanga ukufinyelela iseva.';
}
