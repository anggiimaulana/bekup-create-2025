import 'dart:developer';
import 'dart:isolate';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:food_recognition_app/model/inference_mode.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'isolate_inference.dart';
import 'firebase_ml_service.dart';

class ImageClassificationService {
  // FirebaseMlService untuk model dan labels dari assets
  final FirebaseMlService _mlService;
  final labelsPath = 'assets/models/probability-labels-en.txt';

  // Constructor yang menerima FirebaseMlService
  ImageClassificationService(this._mlService);

  // Setup variables
  late final Interpreter interpreter;
  List<String>? labels;

  late Tensor inputTensor;
  late Tensor outputTensor;
  IsolateInference? isolateInference;
  File? modelFile;

  // Load model Firebase
  Future<void> _loadModel() async {
    try {
      if (modelFile != null) return;

      final options = InterpreterOptions()
        ..useNnApiForAndroid = true
        ..useMetalDelegateForIOS = true;

      modelFile = await _mlService.loadModel();
      interpreter = Interpreter.fromFile(modelFile!, options: options);

      inputTensor = interpreter.getInputTensors().first;
      outputTensor = interpreter.getOutputTensors().first;
    } catch (e) {
      rethrow;
    }
  }

  // Load labels assets
  Future<void> _loadLabels() async {
    try {
      if (labels != null) return;

      final labelTxt = await rootBundle.loadString(labelsPath);
      labels = labelTxt.split('\n').where((label) => label.isNotEmpty).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Initialize everything
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initHelper() async {
    try {
      if (_isInitialized) return;

      await _loadLabels();
      await _loadModel();

      isolateInference = IsolateInference();
      await isolateInference!.start();

      _isInitialized = true;
    } catch (e) {
      rethrow;
    }
  }

  // Inference camera frame
  Future<Map<String, double>> inferenceCameraFrame(
    CameraImage cameraImage,
  ) async {
    try {
      var isolateModel = InferenceModel(
        cameraImage,
        interpreter.address,
        labels!,
        inputTensor.shape,
        outputTensor.shape,
      );

      ReceivePort responsePort = ReceivePort();
      isolateInference!.sendPort.send(
        isolateModel..responsePort = responsePort.sendPort,
      );

      // Get inference result
      var results = await responsePort.first;
      return Map<String, double>.from(results);
    } catch (e) {
      log('Error during inference: $e');
      return {};
    }
  }

  // Close everything
  Future<void> close() async {
    try {
      await isolateInference!.close();
      interpreter.close();
      log('ImageClassificationService closed');
    } catch (e) {
      log('Error closing ImageClassificationService: $e');
    }
  }
}
