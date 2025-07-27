import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite_vision_app/service/image_classification_service.dart';

class ImageClassificationViewModel extends ChangeNotifier {
  final ImageClassificationService _service;

  ImageClassificationViewModel(this._service) {
    _service.initHelper();
  }

  Map<String, num> _classifications = {};

  Map<String, num> get classifications => Map.fromEntries(
    (_classifications.entries.toList()
          ..sort((a, b) => a.value.compareTo(b.value)))
        .reversed
        .take(3),
  );

  Future<void> runClassification(CameraImage camera) async {
    _classifications = await _service.inferenceCameraFrame(camera);
    notifyListeners();
  }

  Future<void> close() async {
    await _service.close();
  }
}
