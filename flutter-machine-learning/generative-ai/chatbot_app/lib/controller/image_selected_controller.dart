import 'package:flutter/widgets.dart';

class ImageSelectedController extends ChangeNotifier {
  int _imageIndex = 0;

  int get imageIndex => _imageIndex;

  set imageIndex(int value) {
    _imageIndex = value;
    notifyListeners();
  }
}
