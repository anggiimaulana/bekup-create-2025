import 'package:chatbot_app/service/image_picker_service.dart';
import 'package:flutter/widgets.dart';

class PhotoController extends ChangeNotifier {
  final ImagePickerService _photoPicker;

  PhotoController(this._photoPicker);

  List<String>? _paths = [];

  List<String>? get paths => _paths;

  Future<void> getPhoto() async {
    _paths = await _photoPicker.getImages();
    notifyListeners();
  }
}
