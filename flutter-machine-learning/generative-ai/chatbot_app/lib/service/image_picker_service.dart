import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  Future<List<String>?> getImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final files = await picker.pickMultiImage();

      return files.map((file) => file.path).toList();
    } catch (e) {
      return null;
    }
  }
}
