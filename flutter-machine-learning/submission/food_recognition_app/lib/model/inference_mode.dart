import 'dart:isolate';

import 'package:camera/camera.dart';

class InferenceModel {
  CameraImage? cameraImage;
  int interpreterAddress;
  List<String> labels;
  List<int> inputShape;
  List<int> outputShape;
  late SendPort responsePort;

  InferenceModel(
    this.cameraImage,
    this.interpreterAddress,
    this.labels,
    this.inputShape,
    this.outputShape,
  );
}
