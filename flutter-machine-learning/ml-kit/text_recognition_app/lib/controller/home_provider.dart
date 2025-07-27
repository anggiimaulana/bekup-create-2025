import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:text_recognition_app/ui/result_page.dart';

class HomeProvider extends ChangeNotifier {
  String? imagePath;

  void _setImageFromGallery(XFile? value) {
    imagePath = value?.path;
    notifyListeners();
  }

  void openGallery() async {
    final picker = ImagePicker();

    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      _setImageFromGallery(pickedFile);
    }
  }

  void goToResultPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResultPage()),
    );
  }
}
