import 'package:flutter/foundation.dart';

class DailyReminderStateProvider extends ChangeNotifier {
  bool _enabled = false;
  bool get isEnabled => _enabled;

  set isEnabled(bool value) {
    _enabled = value;
    notifyListeners();
  }
}
