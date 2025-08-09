import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'firebase_ml_service.dart';
import 'food_image_preprocessor.dart';

class ImageInferenceService {
  final FirebaseMlService _mlService;
  final String labelsPath = 'assets/models/probability-labels-en.txt';

  // Constructor
  ImageInferenceService(this._mlService);

  // Model variables
  late final Interpreter interpreter;
  List<String>? labels;
  late Tensor inputTensor;
  late Tensor outputTensor;
  File? modelFile;
  bool _isInitialized = false;

  // Ensure consistent model specifications
  static const int modelInputWidth = 224;
  static const int modelInputHeight = 224;
  static const int modelInputChannels = 3;
  static const int expectedOutputSize = 2023;

  // Initialize service
  Future<void> initialize() async {
    try {
      if (_isInitialized) return;

      await _loadLabels();
      await _loadModel();
      _validateModelSpecs();

      _isInitialized = true;
    } catch (e) {
      rethrow;
    }
  }

  // Load model from Firebase
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

  // More comprehensive model validation
  void _validateModelSpecs() {
    final inputShape = inputTensor.shape;
    final outputShape = outputTensor.shape;

    // Validate input shape structure
    if (inputShape.length != 4) {
      throw Exception(
        'Model input must be 4D tensor, got ${inputShape.length}D: $inputShape',
      );
    }

    // Check if dimensions match our constants
    if (inputShape[1] != modelInputHeight ||
        inputShape[2] != modelInputWidth ||
        inputShape[3] != modelInputChannels) {
      // Instead of throwing, log warning and continue
      log('WARNING: Model dimensions differ from expected!');
      log(
        'Will force resize all inputs to ${modelInputWidth}x${modelInputHeight}',
      );
    }

    // Validate batch size
    if (inputShape[0] != 1) {
      log('WARNING: Expected batch size 1, got ${inputShape[0]}');
    }

    // Log tensor types for debugging
    if (inputTensor.type == TensorType.uint8) {
      log('INFO: Model uses UINT8 input (0-255 range) - quantized model');
    } else if (inputTensor.type == TensorType.float32) {
      log('INFO: Model uses FLOAT32 input (0.0-1.0 range) - float model');
    } else {
      log('WARNING: Unexpected input tensor type: ${inputTensor.type}');
    }

    // Validate output size
    final outputSize = outputShape.reduce((a, b) => a * b);
    if (outputSize != expectedOutputSize) {
      log('WARNING: Expected $expectedOutputSize outputs, got $outputSize');
    }

    log('Model validation completed');
  }

  // Load labels from assets
  Future<void> _loadLabels() async {
    try {
      if (labels != null) return;

      final labelTxt = await rootBundle.loadString(labelsPath);
      labels = labelTxt
          .split('\n')
          .where((label) => label.trim().isNotEmpty)
          .map((label) => label.trim())
          .toList();

      log('Labels loaded: ${labels!.length} labels');

      if (labels!.length != expectedOutputSize) {
        log(
          'WARNING: Expected $expectedOutputSize labels, got ${labels!.length}',
        );
      }
    } catch (e) {
      log('Error loading labels: $e');
      rethrow;
    }
  }

  // Run inference on image file
  Future<Map<String, double>> predictFromFile(File imageFile) async {
    try {
      if (!_isInitialized) {
        throw Exception('Service not initialized. Call initialize() first.');
      }

      log('Starting prediction for: ${imageFile.path}');

      // Verify file exists and is readable
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist: ${imageFile.path}');
      }

      final fileSize = await imageFile.length();
      if (fileSize == 0) {
        throw Exception('Image file is empty');
      }

      log('Reading image file, size: $fileSize bytes');

      // Load and decode image using image package
      final image = await img.decodeImageFile(imageFile.path);
      if (image == null) {
        throw Exception('Failed to decode image - format may not be supported');
      }

      log('Image decoded successfully: ${image.width}x${image.height}');

      // Use consistent preprocessor
      final preprocessedData = FoodImagePreprocessor.preprocessFileImage(image);

      // Validasi hasil preprocessing
      if (!FoodImagePreprocessor.validateImageMatrix(preprocessedData)) {
        throw Exception('Invalid preprocessing result');
      }

      final matrixInfo = FoodImagePreprocessor.getMatrixInfo(preprocessedData);
      log('Preprocessing info: $matrixInfo');

      // Run inference
      final results = _runInference(preprocessedData);

      log('Prediction completed with ${results.length} results');
      if (results.isNotEmpty) {
        final topResult = results.entries.first;
        log(
          'Top prediction: ${topResult.key} (${(topResult.value * 100).toStringAsFixed(2)}%)',
        );
      }

      return results;
    } catch (e) {
      log('Error during prediction: $e');
      rethrow;
    }
  }

  // Run inference exactly like working camera version
  Map<String, double> _runInference(List<List<List<num>>> imageMatrix) {
    try {
      // Create input exactly like working camera version
      final input = [imageMatrix];

      // Create output exactly like working camera version
      final output = [
        List<int>.filled(outputTensor.shape.reduce((a, b) => a * b), 0),
      ];

      log('Running inference with input type: ${input.runtimeType}');
      log('Output buffer size: ${output[0].length}');

      // Run the model
      interpreter.run(input, output);

      log('Inference completed, processing results...');

      // Process results exactly like working camera version
      return _processResults(output[0]);
    } catch (e) {
      log('Error running inference: $e');
      rethrow;
    }
  }

  // Process model output exactly like the working camera version
  Map<String, double> _processResults(List<int> output) {
    try {
      if (labels == null || labels!.isEmpty) {
        log('No labels available for processing results');
        return {};
      }

      log(
        'Processing results with ${output.length} outputs and ${labels!.length} labels',
      );

      // Calculate normalization factor like in working version
      int maxScore = output.reduce((a, b) => a + b);
      if (maxScore == 0) maxScore = 1; // Prevent division by zero

      // Create classification map
      final classifications = <String, double>{};
      final maxIndex = math.min(output.length, labels!.length);

      for (int i = 0; i < maxIndex; i++) {
        final normalizedValue = output[i].toDouble() / maxScore.toDouble();

        // Only include non-zero values like in working version
        if (normalizedValue > 0) {
          classifications[labels![i]] = normalizedValue;
        }
      }

      // Sort by confidence and return results
      final sortedEntries = classifications.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final results = Map.fromEntries(sortedEntries);

      log('Processed ${results.length} classification results');

      // Log top 5 results for debugging
      final topResults = sortedEntries.take(5);
      log('Top 5 results:');
      for (int i = 0; i < topResults.length; i++) {
        final entry = topResults.elementAt(i);
        log(
          '  ${i + 1}. ${entry.key}: ${(entry.value * 100).toStringAsFixed(2)}%',
        );
      }

      return results;
    } catch (e) {
      log('Error processing results: $e');
      return {};
    }
  }

  // Get top N predictions
  Map<String, double> getTopPredictions(
    Map<String, double> results, {
    int topN = 5,
  }) {
    final sortedEntries = results.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sortedEntries.take(topN));
  }

  // Check if service is initialized
  bool get isInitialized => _isInitialized;

  // Get model specifications
  Map<String, dynamic> get modelSpecs => {
    'inputWidth': modelInputWidth,
    'inputHeight': modelInputHeight,
    'inputChannels': modelInputChannels,
    'expectedOutputs': expectedOutputSize,
    'actualInputShape': _isInitialized ? inputTensor.shape : null,
    'actualOutputShape': _isInitialized ? outputTensor.shape : null,
  };

  // Close the service
  Future<void> close() async {
    try {
      if (modelFile != null) {
        interpreter.close();
      }
      _isInitialized = false;
      log('ImageInferenceService closed');
    } catch (e) {
      log('Error closing ImageInferenceService: $e');
    }
  }
}
