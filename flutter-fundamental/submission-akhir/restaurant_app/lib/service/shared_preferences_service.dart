import 'package:restaurant_app/data/model/setting/setting.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  final SharedPreferences _preferences;

  SharedPreferencesService(this._preferences);

  static const String _keyTheme = 'MY_THEME';
  static const String _keyDailyReminderEnabled = 'DAILY_REMINDER_ENABLED';

  Future<void> saveSettingValue(Setting setting) async {
    try {
      await _preferences.setBool(_keyTheme, setting.themeMode);
      await _preferences.setBool(
        _keyDailyReminderEnabled,
        setting.dailyReminderEnabled,
      );
    } catch (e) {
      throw Exception("Shared preferences cannot save the setting value: $e");
    }
  }

  Setting getSettingValue() {
    return Setting(
      themeMode: _preferences.getBool(_keyTheme) ?? true,
      dailyReminderEnabled:
          _preferences.getBool(_keyDailyReminderEnabled) ?? false,
    );
  }
}
