import 'package:flutter/widgets.dart' show ChangeNotifier;

class ValueHouseDetailProvider extends ChangeNotifier {
  double _value = 0;

  double get value => _value;

  void increment() {
    _value = _value + 0.25;
    notifyListeners();
  }

  void decrement() {
    if (_value == 0) {
      return;
    }
    _value = _value - 0.25;
    notifyListeners();
  }
}

class BedroomsProvider extends ValueHouseDetailProvider {}

class BathroomsProvider extends ValueHouseDetailProvider {}

class FloorsProvider extends ValueHouseDetailProvider {}
