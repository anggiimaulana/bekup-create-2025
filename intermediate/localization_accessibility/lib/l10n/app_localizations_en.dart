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
}
