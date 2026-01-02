import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:media/data/api/api_service.dart';
import 'package:media/data/model/upload_response.dart';

class UploadProvider extends ChangeNotifier {
  final ApiService apiService;
  bool isUploading = false;
  String message = "";
  UploadResponse? uploadResponse;

  UploadProvider(this.apiService);

  Future<void> upload(
    List<int> bytes,
    String filenName,
    String description,
  ) async {
    try {
      message = "";
      uploadResponse = null;
      isUploading = true;
      notifyListeners();

      uploadResponse = await apiService.uploadDocument(
        bytes,
        filenName,
        description,
      );
      message = uploadResponse?.message ?? "success";
      isUploading = false;
      notifyListeners();
    } catch (e) {
      isUploading = false;
      message = e.toString();
      notifyListeners();
    }
  }

  Future<List<int>> compressImage(List<int> bytes) async {
    if (bytes.length <= 1000000) return bytes;

    final image = img.decodeImage(Uint8List.fromList(bytes));
    if (image == null) return bytes;

    int quality = 100;
    List<int> result = bytes;

    while (result.length > 1000000 && quality > 10) {
      quality -= 10;
      result = img.encodeJpg(image, quality: quality);
    }

    return result;
  }
}
