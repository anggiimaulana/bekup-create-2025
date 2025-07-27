import 'package:flutter/foundation.dart';
import 'package:restaurant_app/data/model/setting/setting.dart';
import 'package:restaurant_app/service/shared_preferences_service.dart';
import 'package:restaurant_app/utils/theme_state.dart';

class ThemeStateProvider extends ChangeNotifier {
  ThemeState _themeState = ThemeState.lightTheme;
  final SharedPreferencesService _prefsService;

  ThemeStateProvider(this._prefsService) {
    _loadThemeFromPrefs();
  }

  ThemeState get notificationState => _themeState;

  set notificationState(ThemeState value) {
    _themeState = value;

    final oldSetting = _prefsService.getSettingValue();
    final newSetting = Setting(
      themeMode: value == ThemeState.lightTheme,
      dailyReminderEnabled: oldSetting.dailyReminderEnabled,
    );
    _prefsService.saveSettingValue(newSetting);

    notifyListeners();
  }

  void _loadThemeFromPrefs() {
    final setting = _prefsService.getSettingValue();
    _themeState = setting.themeMode
        ? ThemeState.lightTheme
        : ThemeState.darkTheme;
    notifyListeners();
  }
}
