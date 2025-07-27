import 'dart:developer';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_vision_app/service/isolate_inference.dart';

class ImageClassificationService {
  final modelPath = 'assets/mobilenet.tflite';
  final labelsPath = 'assets/labels.txt';

  late final Interpreter interpreter;
  late final List<String> labels;
  late Tensor inputTensor;
  late Tensor outputTensor;

  late final IsolateInference isolateInference;

  Future<void> _loadModel() async {
    final options = InterpreterOptions()
      ..useNnApiForAndroid = true
      ..useMetalDelegateForIOS = true;

    // load model from assets
    interpreter = await Interpreter.fromAsset(modelPath, options: options);

    // get tensor input shape [1, 224,224, 3]
    inputTensor = interpreter.getInputTensors().first;

    // get tensor output shape [1, 1001]
    outputTensor = interpreter.getInputTensors().first;

    log('Interpreter loaded successfully');
  }

  Future<void> _loadLabels() async {
    final labelTxt = await rootBundle.loadString(labelsPath);
    labels = labelTxt.split('\n');
  }

  Future<void> initHelper() async {
    _loadLabels();
    _loadModel();
    isolateInference = IsolateInference();
    await isolateInference.start();
  }

  Future<Map<String, double>> inferenceCameraFrame(
    CameraImage cameraImage,
  ) async {
    var isolateModel = InferenceModel(
      cameraImage,
      interpreter.address,
      labels,
      inputTensor.shape,
      outputTensor.shape,
    );

    ReceivePort responsePort = ReceivePort();
    isolateInference.sendPort.send(
      isolateModel..responsePort = responsePort.sendPort,
    );

    // get inference result
    var result = await responsePort.first;
    return result;
  }

  Future<void> close() async {
    await isolateInference.close();
  }
}
