// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get titleAppBar => 'Dicoding Academy';

  @override
  String get costTitle => 'Biaya Langganan';

  @override
  String get costSubtitle =>
      'Pilih paket langganan sebagai investasi belajar yang sesuai dengan kebutuhan Anda.';

  @override
  String paidPackageTitle(int month) {
    String _temp0 = intl.Intl.pluralLogic(
      month,
      locale: localeName,
      other: '$month bulan',
    );
    return 'Berlangganan $_temp0';
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
  String get paidPackageButton => 'Pilih Paket';

  @override
  String get orText => 'atau';

  @override
  String freePackageTitle(int day) {
    String _temp0 = intl.Intl.pluralLogic(
      day,
      locale: localeName,
      other: '$day hari',
    );
    return 'Berlangganan $_temp0';
  }

  @override
  String get freePackagePrice => 'Gratis';

  @override
  String get freePackageButton => 'Coba sekarang';

  @override
  String get benefitTitle => 'Keuntungan Langganan';

  @override
  String get benefitFeatureTitle1 => 'Fitur Utama';

  @override
  String get benefitFeatureTitle2 => 'Uji Coba';

  @override
  String get benefitFeatureTitle3 => 'Langganan';

  @override
  String get benefitFeatureItem1 => 'Akses semua kelas';

  @override
  String get benefitFeatureItem2 => 'Ujian';

  @override
  String get benefitFeatureItem3 => 'Kirim Proyek';
}
