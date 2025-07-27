import 'dart:developer';
import 'dart:io';

import 'package:house_price_predictor_app/service/firebase_ml_service.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class LiteRtService {
  // final modelPath = 'assets/house_price_prediction.tflite';
  final FirebaseMlService _mlService;

  LiteRtService(this._mlService);

  late final File modelFile;

  late final Interpreter interpreter;
  late final List<String> labels;
  late List inputFormat;
  late List outputFormat;

  Future<void> initModel() async {
    modelFile = await _mlService.loadModel();

    final options = InterpreterOptions()
      ..useNnApiForAndroid = true
      ..useMetalDelegateForIOS = true;

    // load model from assets
    interpreter = Interpreter.fromFile(modelFile, options: options);

    // get tensor output shape [1,1]
    final outputTensor = interpreter.getOutputTensors().first;
    final outputShape = outputTensor.shape;
    log("outputShape: $outputShape");

    // create a list [1,1]
    outputFormat = List.generate(
      outputShape.first,
      (_) => List.generate(outputShape.last, (_) => 0.0),
    );
    log("outputFormat: $outputFormat");

    log("Interpreter loaded successfully");
  }

  double inference(List<double> number) {
    // get tensor input shape [1,4,1]
    final inputTensor = interpreter.getInputTensors().first;
    final inputShape = inputTensor.shape;
    log("inputShape: $inputShape");

    // create a list [1,4,1]
    inputFormat = List.generate(
      inputShape.first,
      (_) => List.generate(
        inputShape[1],
        (i) => List.generate(inputShape.last, (_) => number[i]),
      ),
    );
    log("inputFormat: $inputFormat");

    interpreter.run(inputFormat, outputFormat);

    final result = outputFormat.first.first;
    log("outputFormat: $result (after)");
    return result;
  }

  void close() {
    interpreter.close();
  }
}
