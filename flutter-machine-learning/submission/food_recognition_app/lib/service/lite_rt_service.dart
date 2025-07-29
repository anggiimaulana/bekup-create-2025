import 'dart:developer';
import 'dart:io';

import 'package:food_recognition_app/service/firebase_ml_service.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class LiteRtService {
  // todo-04: add new property and constructor to get a firebase ml service
  final FirebaseMlService _mlService;

  LiteRtService(this._mlService);

  late final File modelFile;

  late final Interpreter interpreter;
  late final List<String> labels;
  late List inputFormat;
  late List outputFormat;

  Future<void> initModel() async {
    // todo-05: replace a asset path, use a model file, load a model from file
    modelFile = await _mlService.loadModel();

    final options = InterpreterOptions()
      ..useNnApiForAndroid = true
      ..useMetalDelegateForIOS = true;

    // Load model from assets
    interpreter = Interpreter.fromFile(modelFile, options: options);
    // Get tensor output shape [1, 1]
    final outputTensor = interpreter.getOutputTensors().first;
    final outputShape = outputTensor.shape;
    log('outputShape: $outputShape');
    // Create a list [1, 1]
    outputFormat = List.generate(
      outputShape.first,
      (_) => List.generate(outputShape.last, (_) => 0.0),
    );
    log('outputFormat: $outputFormat');

    log('Interpreter loaded successfully');
  }

  double inference(List<double> number) {
    // Get tensor input shape [1, 4, 1]
    final inputTensor = interpreter.getInputTensors().first;
    final inputShape = inputTensor.shape;
    log('inputShape: $inputShape');
    // Create a list [1, 4, 1]
    inputFormat = List.generate(
      inputShape.first,
      (_) => List.generate(
        inputShape[1],
        (i) => List.generate(inputShape.last, (_) => number[i]),
      ),
    );
    log('inputFormat: $inputFormat');

    interpreter.run(inputFormat, outputFormat);

    final result = outputFormat.first.first;
    log('outputFormat: $outputFormat (after)');
    return result;
  }

  void close() {
    interpreter.close();
  }
}
