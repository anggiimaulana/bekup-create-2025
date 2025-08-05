import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:food_recognition_app/model/inference_mode.dart';
import 'dart:math' as math;
import 'package:image/image.dart' as image_lib;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../utils/image_utils.dart';

class IsolateInference {
  static const String _debugName = "TFLITE_INFERENCE";
  final ReceivePort _receivePort = ReceivePort();
  late Isolate _isolate;
  late SendPort _sendPort;
  SendPort get sendPort => _sendPort;

  // FIXED: Add constants for model dimensions
  static const int MODEL_INPUT_WIDTH = 224;
  static const int MODEL_INPUT_HEIGHT = 224;
  static const int MODEL_INPUT_CHANNELS = 3;

  Future<void> start() async {
    _isolate = await Isolate.spawn<SendPort>(
      entryPoint,
      _receivePort.sendPort,
      debugName: _debugName,
    );
    _sendPort = await _receivePort.first;
  }

  static void entryPoint(SendPort sendPort) async {
    final port = ReceivePort();
    sendPort.send(port.sendPort);

    await for (final InferenceModel isolateModel in port) {
      try {
        final cameraImage = isolateModel.cameraImage!;

        // FIXED: Process image exactly like working version
        final inputShape = isolateModel.inputShape;
        final imageMatrix = _imagePreProcessing(cameraImage, inputShape);

        // FIXED: Create input and output exactly like working version
        final input = [imageMatrix];
        final output = [List<int>.filled(isolateModel.outputShape[1], 0)];
        final address = isolateModel.interpreterAddress;

        // Run inference
        final result = _runInference(input, output, address);

        // FIXED: Process results exactly like working version
        int maxScore = result.reduce((a, b) => a + b);
        final keys = isolateModel.labels;
        final values = result
            .map((e) => e.toDouble() / maxScore.toDouble())
            .toList();

        var classification = Map.fromIterables(keys, values);
        // FIXED: Remove zero values like working version
        classification.removeWhere((key, value) => value == 0);

        // Send result to main thread
        isolateModel.responsePort.send(classification);
      } catch (e) {
        print('Error in isolate inference: $e');
        isolateModel.responsePort.send(<String, double>{});
      }
    }
  }

  // FIXED: Use the same preprocessing as working version
  static List<List<List<num>>> _imagePreProcessing(
    CameraImage cameraImage,
    List<int> inputShape,
  ) {
    image_lib.Image? img = ImageUtils.convertCameraImage(cameraImage);

    if (img == null) {
      throw Exception('Failed to convert camera image');
    }

    // resize original image to match model shape.
    image_lib.Image imageInput = image_lib.copyResize(
      img,
      width: inputShape[1],
      height: inputShape[2],
    );

    if (Platform.isAndroid) {
      imageInput = image_lib.copyRotate(imageInput, angle: 90);
    }

    final imageMatrix = List.generate(
      imageInput.height,
      (y) => List.generate(imageInput.width, (x) {
        final pixel = imageInput.getPixel(x, y);
        return [pixel.r, pixel.g, pixel.b];
      }),
    );
    return imageMatrix;
  }

  // FIXED: Use exact same inference method as working version
  static List<int> _runInference(
    List<List<List<List<num>>>> input,
    List<List<int>> output,
    int interpreterAddress,
  ) {
    Interpreter interpreter = Interpreter.fromAddress(interpreterAddress);
    interpreter.run(input, output);
    // Get first output tensor
    final result = output.first;
    return result;
  }

  // Close isolate
  Future<void> close() async {
    _isolate.kill();
    _receivePort.close();
  }
}
