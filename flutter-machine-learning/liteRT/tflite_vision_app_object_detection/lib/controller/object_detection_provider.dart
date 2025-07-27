import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:tflite_vision_app_object_detection/model/detected_object.dart';
import 'package:tflite_vision_app_object_detection/service/object_detection_service.dart';

// todo-04-viewmodel-01: create a viewmodel notifier
class ObjectDetectionViewmodel extends ChangeNotifier {
  // todo-04-viewmodel-02: create a constructor
  final ObjectDetectionService _service;

  ObjectDetectionViewmodel(this._service) {
    _service.initHelper();
  }

  // todo-04-viewmodel-03: create a state and getter to get a top three on classification item
  List<DetectedObject> _detectedObjects = [];

  List<DetectedObject> get detectedObjects =>
      _detectedObjects.where((e) => e.score >= 0.5).toList();

  // todo-04-viewmodel-04: run the inference process
  Future<void> runDetection(CameraImage camera) async {
    _detectedObjects = await _service.inferenceCameraFrame(camera);
    notifyListeners();
  }

  // todo-04-viewmodel-05: close everything
  Future<void> close() async {
    await _service.close();
  }
}
