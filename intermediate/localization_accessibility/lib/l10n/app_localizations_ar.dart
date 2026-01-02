// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get titleAppBar => 'Dicoding Academy';

  @override
  String get costTitle => 'رسم الاشتراك';

  @override
  String get costSubtitle =>
      'اختر حزمة اشتراك كاستثمار تعليمي يناسب احتياجاتك.';

  @override
  String paidPackageTitle(int month) {
    String _temp0 = intl.Intl.pluralLogic(
      month,
      locale: localeName,
      other: 'اشتراك $month شهور',
      two: 'اشتراك شهرين',
      one: 'اشتراك لمدة شهر',
    );
    return '$_temp0';
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
  String get paidPackageButton => 'اختر الباقة';

  @override
  String get orText => 'أو';

  @override
  String freePackageTitle(int day) {
    String _temp0 = intl.Intl.pluralLogic(
      day,
      locale: localeName,
      other: 'اشتراك $day يوم',
      two: 'اشتراك لمدة 2 يوم',
      one: 'اشتراك ليوم واحد',
    );
    return '$_temp0';
  }

  @override
  String get freePackagePrice => 'حر';

  @override
  String get freePackageButton => 'جرب الآن';

  @override
  String get benefitTitle => 'ميزة الاشتراك';

  @override
  String get benefitFeatureTitle1 => 'الميزة الأساسية';

  @override
  String get benefitFeatureTitle2 => 'محاكمة';

  @override
  String get benefitFeatureTitle3 => 'الاشتراك';

  @override
  String get benefitFeatureItem1 => 'دورة بلا حدود';

  @override
  String get benefitFeatureItem2 => 'امتحان';

  @override
  String get benefitFeatureItem3 => 'أرسل المشروع';
}
