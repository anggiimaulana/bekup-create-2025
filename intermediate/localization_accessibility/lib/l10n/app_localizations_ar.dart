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

  @override
  String get accLogoAppBar => 'Logo Dicoding Academy';

  @override
  String get accTitleAppBar => 'Dicoding Academy';

  @override
  String get accHeader =>
      'Biaya Langganan, Pilih paket langganan sebagai investasi belajar yang sesuai dengan kebutuhan Anda.';

  @override
  String accPaidPackage(String paidPackageTitle, String paidPackagePrice) {
    return 'Anda dapat $paidPackageTitle dengan biaya $paidPackagePrice';
  }

  @override
  String get accPaidPackageButton => 'Pilih Paket untuk berlangganan';

  @override
  String get accOrText => 'atau';

  @override
  String accFreePackage(String freePackageTitle, String freePackagePrice) {
    return 'Anda dapat uji coba dengan $freePackageTitle secara $freePackagePrice';
  }

  @override
  String get accFreePackageButton => 'Coba Sekarang';

  @override
  String get accBenefitTitle => 'Keuntungan Langganan';

  @override
  String accBenefitFeatureItem1(String benefitFeatureItem1) {
    return 'Fitur $benefitFeatureItem1, tersedia di langganan uji coba, tersedia di langganan berbayar.';
  }

  @override
  String accBenefitFeatureItem2(String benefitFeatureItem2) {
    return 'Fitur $benefitFeatureItem2, tersedia di langganan uji coba, tersedia di langganan berbayar.';
  }

  @override
  String accBenefitFeatureItem3(String benefitFeatureItem3) {
    return 'Fitur $benefitFeatureItem3, tidak tersedia di langganan uji coba, tersedia di langganan berbayar.';
  }

  @override
  String get accChangeLanguage => 'Pengaturan ubah bahasa';

  @override
  String get accOpenSetting => 'Buka pengaturan';

  @override
  String get accLocaleItem1 => 'Bahasa Indonesia';

  @override
  String get accLocaleItem2 => 'Bahasa Inggris';

  @override
  String get accLocaleItem3 => 'Bahasa Arab';
}
