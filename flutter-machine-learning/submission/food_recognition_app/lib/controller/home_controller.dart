import 'package:flutter/material.dart';
import 'package:food_recognition_app/ui/result_page.dart';

class HomeController extends ChangeNotifier {
  void goToResultPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResultPage()),
    );
  }
}
