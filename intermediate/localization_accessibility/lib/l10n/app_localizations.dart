import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('ar'),
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @titleAppBar.
  ///
  /// In id, this message translates to:
  /// **'Dicoding Academy'**
  String get titleAppBar;

  /// No description provided for @costTitle.
  ///
  /// In id, this message translates to:
  /// **'Biaya Langganan'**
  String get costTitle;

  /// No description provided for @costSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih paket langganan sebagai investasi belajar yang sesuai dengan kebutuhan Anda.'**
  String get costSubtitle;

  /// No description provided for @paidPackageTitle.
  ///
  /// In id, this message translates to:
  /// **'Berlangganan {month,plural, other{{month} bulan}}'**
  String paidPackageTitle(int month);

  /// No description provided for @paidPackagePrice.
  ///
  /// In id, this message translates to:
  /// **'{feeSubscription}'**
  String paidPackagePrice(int feeSubscription);

  /// No description provided for @paidPackageButton.
  ///
  /// In id, this message translates to:
  /// **'Pilih Paket'**
  String get paidPackageButton;

  /// No description provided for @orText.
  ///
  /// In id, this message translates to:
  /// **'atau'**
  String get orText;

  /// No description provided for @freePackageTitle.
  ///
  /// In id, this message translates to:
  /// **'Berlangganan {day,plural, other{{day} hari}}'**
  String freePackageTitle(int day);

  /// No description provided for @freePackagePrice.
  ///
  /// In id, this message translates to:
  /// **'Gratis'**
  String get freePackagePrice;

  /// No description provided for @freePackageButton.
  ///
  /// In id, this message translates to:
  /// **'Coba sekarang'**
  String get freePackageButton;

  /// No description provided for @benefitTitle.
  ///
  /// In id, this message translates to:
  /// **'Keuntungan Langganan'**
  String get benefitTitle;

  /// No description provided for @benefitFeatureTitle1.
  ///
  /// In id, this message translates to:
  /// **'Fitur Utama'**
  String get benefitFeatureTitle1;

  /// No description provided for @benefitFeatureTitle2.
  ///
  /// In id, this message translates to:
  /// **'Uji Coba'**
  String get benefitFeatureTitle2;

  /// No description provided for @benefitFeatureTitle3.
  ///
  /// In id, this message translates to:
  /// **'Langganan'**
  String get benefitFeatureTitle3;

  /// No description provided for @benefitFeatureItem1.
  ///
  /// In id, this message translates to:
  /// **'Akses semua kelas'**
  String get benefitFeatureItem1;

  /// No description provided for @benefitFeatureItem2.
  ///
  /// In id, this message translates to:
  /// **'Ujian'**
  String get benefitFeatureItem2;

  /// No description provided for @benefitFeatureItem3.
  ///
  /// In id, this message translates to:
  /// **'Kirim Proyek'**
  String get benefitFeatureItem3;
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
      <String>['ar', 'en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
