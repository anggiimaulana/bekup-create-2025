// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get titleAppBar => 'Dicoding Academy';

  @override
  String get costTitle => 'Subscription Fee';

  @override
  String get costSubtitle =>
      'Choose a subscription package as a learning investment that suits your needs.';

  @override
  String paidPackageTitle(int month) {
    String _temp0 = intl.Intl.pluralLogic(
      month,
      locale: localeName,
      other: '$month Months',
      one: '$month Month',
    );
    return '$_temp0 Subscription';
  }

  @override
  String paidPackagePrice(int feeSubscription) {
    final intl.NumberFormat feeSubscriptionNumberFormat =
        intl.NumberFormat.simpleCurrency(locale: localeName, decimalDigits: 0);
    final String feeSubscriptionString = feeSubscriptionNumberFormat.format(
      feeSubscription,
    );

    return '$feeSubscriptionString';
  }

  @override
  String get paidPackageButton => 'Choose Package';

  @override
  String get orText => 'or';

  @override
  String freePackageTitle(int day) {
    String _temp0 = intl.Intl.pluralLogic(
      day,
      locale: localeName,
      other: '$day days',
      one: '$day day',
    );
    return '$_temp0 Subscription';
  }

  @override
  String get freePackagePrice => 'Free';

  @override
  String get freePackageButton => 'Try Now';

  @override
  String get benefitTitle => 'Subscription Benefit';

  @override
  String get benefitFeatureTitle1 => 'Main Feature';

  @override
  String get benefitFeatureTitle2 => 'Trial';

  @override
  String get benefitFeatureTitle3 => 'Subscription';

  @override
  String get benefitFeatureItem1 => 'All-Access Course';

  @override
  String get benefitFeatureItem2 => 'Exam';

  @override
  String get benefitFeatureItem3 => 'Send Project';

  @override
  String get accLogoAppBar => 'Logo Dicoding Academy';

  @override
  String get accTitleAppBar => 'Dicoding Academy';

  @override
  String get accHeader =>
      'Subscription Fee, Choose a subscription package as a learning investment that suits your needs.';

  @override
  String accPaidPackage(String paidPackageTitle, String paidPackagePrice) {
    return 'You can get a $paidPackageTitle for $paidPackagePrice';
  }

  @override
  String get accPaidPackageButton => 'Choose Package for Subscription';

  @override
  String get accOrText => 'or';

  @override
  String accFreePackage(String freePackageTitle, String freePackagePrice) {
    return 'You can get a trial with $freePackageTitle for $freePackagePrice';
  }

  @override
  String get accFreePackageButton => 'Try Now';

  @override
  String get accBenefitTitle => 'Subscription Benefit';

  @override
  String accBenefitFeatureItem1(String benefitFeatureItem1) {
    return '$benefitFeatureItem1 Feature, available on trial subscriptions, available on paid subscriptions.';
  }

  @override
  String accBenefitFeatureItem2(String benefitFeatureItem2) {
    return '$benefitFeatureItem2 Feature, available on trial subscriptions, available on paid subscriptions.';
  }

  @override
  String accBenefitFeatureItem3(String benefitFeatureItem3) {
    return '$benefitFeatureItem3 Feature, not available on trial subscriptions, available on paid subscriptions.';
  }

  @override
  String get accChangeLanguage => 'Change Language Setting';

  @override
  String get accOpenSetting => 'Open settings';

  @override
  String get accLocaleItem1 => 'Indonesian';

  @override
  String get accLocaleItem2 => 'Inggris';

  @override
  String get accLocaleItem3 => 'Arabic';
}
