import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:tflite_vision_app_object_detection/model/detected_object.dart';
import 'package:tflite_vision_app_object_detection/service/object_detection_service.dart';

class ObjectDetectionViewmodel extends ChangeNotifier {
  final ObjectDetectionService _service;

  ObjectDetectionViewmodel(this._service) {
    _service.initHelper();
  }

  // todo-02-inference-07: change the state and function name
  List<DetectedObject> _detectedObjects = [];

  List<DetectedObject> get detectedObjects =>
      _detectedObjects.where((e) => e.score >= 0.5).toList();

  Future<void> runDetection(CameraImage camera) async {
    _detectedObjects = await _service.inferenceCameraFrame(camera);
    notifyListeners();
  }

  Future<void> close() async {
    await _service.close();
  }
}
