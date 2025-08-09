import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:food_recognition_app/service/image_inference_service.dart';

class GalleryPredictionController extends ChangeNotifier {
  ImageInferenceService _inferenceService;

  // State variables
  bool _isInitialized = false;
  bool _isLoading = false;
  Map<String, double> _predictions = {};
  String? _errorMessage;
  DateTime? _lastPredictionTime;

  // Constructor
  GalleryPredictionController(this._inferenceService);

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  Map<String, double> get predictions => _predictions;
  String? get errorMessage => _errorMessage;
  DateTime? get lastPredictionTime => _lastPredictionTime;

  // Get formatted predictions for UI display
  Map<String, String> get formattedPredictions {
    return _predictions.map((key, value) {
      final percentage = (value * 100).toStringAsFixed(1);
      return MapEntry(key, '$percentage%');
    });
  }

  // FIXED: Get top predictions with confidence threshold like working camera version
  Map<String, String> getFormattedTopPredictions({
    int topN = 5,
    double minConfidence = 0.1, // FIXED: Use 10% like camera version, not 1%
  }) {
    final filteredPredictions = Map<String, double>.from(_predictions)
      ..removeWhere((key, value) => value < minConfidence);

    final sortedEntries = filteredPredictions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topEntries = sortedEntries.take(topN);

    return Map.fromEntries(
      topEntries.map((entry) {
        final percentage = (entry.value * 100).toStringAsFixed(1);
        return MapEntry(entry.key, '$percentage%');
      }),
    );
  }

  // Update inference service (called by provider)
  void updateInferenceService(ImageInferenceService newService) {
    if (_inferenceService != newService) {
      _inferenceService = newService;
      // Reset initialization status to ensure new service is properly initialized
      _isInitialized = false;
    }
  }

  // Initialize the service with validation
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _setLoading(true);
      _clearError();

      log('Initializing GalleryPredictionController...');

      // Initialize the inference service
      await _inferenceService.initialize();

      // Validate model specifications
      final modelSpecs = _inferenceService.modelSpecs;
      log('Model specifications: $modelSpecs');

      _isInitialized = true;
      log('GalleryPredictionController initialized successfully');
    } catch (e) {
      final errorMsg = 'Failed to initialize prediction service: $e';
      _setError(errorMsg);
      log('Error initializing GalleryPredictionController: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Predict from image file with comprehensive error handling
  Future<void> predictFromFile(File imageFile) async {
    try {
      _setLoading(true);
      _clearError();
      _predictions.clear();

      log('=== Starting Gallery Image Prediction ===');
      log('Image path: ${imageFile.path}');

      // Ensure service is initialized
      if (!_isInitialized) {
        log('Service not initialized, initializing...');
        await initialize();
      }

      // Comprehensive file validation
      await _validateImageFile(imageFile);

      log('Running prediction on image...');
      final startTime = DateTime.now();

      // Run prediction
      final results = await _inferenceService.predictFromFile(imageFile);

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      log('Prediction completed in ${duration.inMilliseconds}ms');

      if (results.isEmpty) {
        throw Exception('No predictions returned from model');
      }

      // FIXED: Filter results like working camera version (>10% confidence)
      final filteredResults = Map<String, double>.from(results);
      filteredResults.removeWhere((key, value) => value <= 0.1);

      // Store results and update timestamp
      _predictions = filteredResults;
      _lastPredictionTime = DateTime.now();

      // Log prediction summary
      final topPredictions = getFormattedTopPredictions(topN: 3);
      log('Top 3 predictions (>10% confidence):');
      topPredictions.entries.forEach((entry) {
        log('  ${entry.key}: ${entry.value}');
      });

      log('=== Prediction completed successfully ===');
    } catch (e) {
      final errorMsg = 'Prediction failed: $e';
      _setError(errorMsg);
      log('Error in predictFromFile: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Validate image file before prediction
  Future<void> _validateImageFile(File imageFile) async {
    // Check if file exists
    if (!await imageFile.exists()) {
      throw Exception('Image file does not exist');
    }

    // Check file size
    final fileSize = await imageFile.length();
    if (fileSize == 0) {
      throw Exception('Image file is empty');
    }

    // Check file size limits (e.g., max 10MB)
    const maxFileSize = 10 * 1024 * 1024; // 10MB
    if (fileSize > maxFileSize) {
      throw Exception(
        'Image file too large (${(fileSize / 1024 / 1024).toStringAsFixed(1)}MB). Maximum size: ${maxFileSize / 1024 / 1024}MB',
      );
    }

    // Check file extension
    final extension = imageFile.path.split('.').last.toLowerCase();
    const supportedExtensions = ['jpg', 'jpeg', 'png', 'bmp', 'webp'];
    if (!supportedExtensions.contains(extension)) {
      throw Exception(
        'Unsupported image format: $extension. Supported formats: ${supportedExtensions.join(', ')}',
      );
    }

    log(
      'Image file validation passed: ${(fileSize / 1024).toStringAsFixed(1)}KB, format: $extension',
    );
  }

  // Predict with retry mechanism
  Future<void> predictFromFileWithRetry(
    File imageFile, {
    int maxRetries = 2,
    Duration retryDelay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts <= maxRetries) {
      try {
        await predictFromFile(imageFile);
        return; // Success, exit retry loop
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        attempts++;

        log('Prediction attempt $attempts failed: $e');

        if (attempts <= maxRetries) {
          log('Retrying in ${retryDelay.inSeconds} seconds...');
          await Future.delayed(retryDelay);
        }
      }
    }

    // All attempts failed
    throw lastException ?? Exception('All prediction attempts failed');
  }

  // Get top N predictions
  Map<String, double> getTopPredictions(int n) {
    final sortedEntries = _predictions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries.take(n));
  }

  // FIXED: Get predictions above confidence threshold like camera version
  Map<String, double> getPredictionsAboveThreshold(double threshold) {
    final filteredPredictions = Map<String, double>.from(_predictions);
    filteredPredictions.removeWhere((key, value) => value < threshold);

    final sortedEntries = filteredPredictions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries);
  }

  // Clear predictions
  void clearPredictions() {
    _predictions.clear();
    _lastPredictionTime = null;
    _clearError();
    notifyListeners();
  }

  // Reset controller state
  void reset() {
    _predictions.clear();
    _isLoading = false;
    _lastPredictionTime = null;
    _clearError();
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  // Check if we have predictions
  bool get hasPredictions => _predictions.isNotEmpty;

  // Get confidence for specific prediction
  double? getConfidence(String label) {
    return _predictions[label];
  }

  // Get formatted confidence string
  String getFormattedConfidence(String label) {
    final confidence = _predictions[label];
    if (confidence == null) return 'N/A';
    return '${(confidence * 100).toStringAsFixed(1)}%';
  }

  // Get prediction statistics
  Map<String, dynamic> get predictionStats {
    if (_predictions.isEmpty) {
      return {
        'totalPredictions': 0,
        'maxConfidence': 0.0,
        'minConfidence': 0.0,
        'avgConfidence': 0.0,
        'lastPredictionTime': null,
      };
    }

    final confidences = _predictions.values.toList();
    final maxConfidence = confidences.reduce((a, b) => a > b ? a : b);
    final minConfidence = confidences.reduce((a, b) => a < b ? a : b);
    final avgConfidence =
        confidences.reduce((a, b) => a + b) / confidences.length;

    return {
      'totalPredictions': _predictions.length,
      'maxConfidence': maxConfidence,
      'minConfidence': minConfidence,
      'avgConfidence': avgConfidence,
      'lastPredictionTime': _lastPredictionTime,
    };
  }

  // Service status information
  Map<String, dynamic> get serviceStatus => {
    'isInitialized': _isInitialized,
    'isLoading': _isLoading,
    'hasError': _errorMessage != null,
    'errorMessage': _errorMessage,
    'hasPredictions': hasPredictions,
    'predictionsCount': _predictions.length,
  };

  @override
  void dispose() {
    // Clean up resources
    _predictions.clear();
    super.dispose();
  }
}
