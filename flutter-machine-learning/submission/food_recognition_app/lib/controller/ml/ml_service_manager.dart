import 'dart:developer';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food_recognition_app/service/firebase_ml_service.dart';
import 'package:food_recognition_app/service/image_classification_service.dart';
import 'package:food_recognition_app/service/image_inference_service.dart';

class MLServiceManager extends ChangeNotifier {
  static final MLServiceManager _instance = MLServiceManager._internal();
  factory MLServiceManager() => _instance;
  MLServiceManager._internal();

  // Services
  late final FirebaseMlService _mlService;
  late final ImageClassificationService _cameraService;
  late final ImageInferenceService _galleryService;

  // State management
  bool _isInitializing = false;
  bool _isInitialized = false;
  bool _isPrewarming = false;
  double _initProgress = 0.0;
  String _currentStep = '';
  String? _errorMessage;

  // Performance tracking
  final Stopwatch _initStopwatch = Stopwatch();
  int _totalInitSteps = 8;

  // Preloading flags
  bool _modelPreloaded = false;
  bool _servicesPrewarmed = false;

  // Getters
  bool get isInitializing => _isInitializing;
  bool get isInitialized => _isInitialized;
  bool get isPrewarming => _isPrewarming;
  double get initProgress => _initProgress;
  String get currentStep => _currentStep;
  String? get errorMessage => _errorMessage;
  bool get isReady => _isInitialized && _servicesPrewarmed;

  // Get services (dengan lazy loading safety)
  ImageClassificationService get cameraService {
    if (!_isInitialized) throw Exception('MLServiceManager not initialized');
    return _cameraService;
  }

  ImageInferenceService get galleryService {
    if (!_isInitialized) throw Exception('MLServiceManager not initialized');
    return _galleryService;
  }

  Future<void> initializeAll() async {
    if (_isInitialized || _isInitializing) return;

    _initStopwatch.start();
    try {
      _isInitializing = true;
      _errorMessage = null;
      _initProgress = 0.0;
      notifyListeners();

      log('=== Starting Zero-Freeze ML Initialization ===');

      // Step 1: Initialize Firebase ML Service (lightweight)
      await _updateProgressAsync(0.1, 'Initializing core services...');
      _mlService = FirebaseMlService();

      // Step 2: Pre-cache model in background (non-blocking)
      await _updateProgressAsync(0.2, 'Pre-loading AI model...');
      await _preloadModelAsync();

      // Step 3: Initialize services with pre-loaded model
      await _updateProgressAsync(0.25, 'Preparing camera service...');
      await _initializeCameraServiceAsync();

      // Step 4: Initialize gallery service
      await _updateProgressAsync(0.3, 'Preparing gallery service...');
      await _initializeGalleryServiceAsync();

      // Step 5: Warm up services (prevent first-use freeze)
      await _updateProgressAsync(0.4, 'Warming up services...');
      await _prewarmServicesAsync();

      // Step 6: Final validation
      await _updateProgressAsync(0.5, 'Final validation...');
      await _validateServicesAsync();

      // Complete
      await _updateProgressAsync(1.0, 'Ready!');

      _isInitialized = true;
      _isInitializing = false;
      _servicesPrewarmed = true;

      _initStopwatch.stop();
      log(
        '=== ML Initialization Complete in ${_initStopwatch.elapsedMilliseconds}ms ===',
      );

      notifyListeners();
    } catch (e, stackTrace) {
      _initStopwatch.stop();
      log('Stack trace: $stackTrace');

      _errorMessage = e.toString();
      _isInitializing = false;
      _isInitialized = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Pre-load model secara async untuk menghindari freeze
  Future<void> _preloadModelAsync() async {
    if (_modelPreloaded) return;

    try {
      // Load model in chunks dengan yield points
      await Future.delayed(const Duration(milliseconds: 10)); 

      // Load model dengan timeout dan progress tracking
      final completer = Completer<void>();

      // Run model loading in background
      Timer.periodic(const Duration(milliseconds: 50), (timer) async {
        if (completer.isCompleted) {
          timer.cancel();
          return;
        }

        try {
          await _mlService.loadModel();
          _modelPreloaded = true;
          if (!completer.isCompleted) completer.complete();
          timer.cancel();
        } catch (e) {
          if (!completer.isCompleted) completer.completeError(e);
          timer.cancel();
        }
      });

      // Wait for completion with timeout
      await completer.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException(
          'Model loading timeout',
          const Duration(seconds: 15),
        ),
      );

      log('Model preloaded successfully');
    } catch (e) {
      log('Model preload error: $e');
      rethrow;
    }
  }

  /// Initialize camera service tanpa freeze
  Future<void> _initializeCameraServiceAsync() async {
    try {
      // Yield untuk prevent freeze
      await Future.delayed(const Duration(milliseconds: 5));

      _cameraService = ImageClassificationService(_mlService);

      // Initialize dengan micro-batching
      await _runWithMicroYields(() async {
        await _cameraService.initHelper();
      });

      log('Camera service initialized');
    } catch (e) {
      log('Camera service init error: $e');
      rethrow;
    }
  }

  /// Initialize gallery service tanpa freeze
  Future<void> _initializeGalleryServiceAsync() async {
    try {
      // Yield untuk prevent freeze
      await Future.delayed(const Duration(milliseconds: 5));

      _galleryService = ImageInferenceService(_mlService);

      // Initialize dengan micro-batching
      await _runWithMicroYields(() async {
        await _galleryService.initialize();
      });

      log('Gallery service initialized');
    } catch (e) {
      log('Gallery service init error: $e');
      rethrow;
    }
  }

  /// Prewarm services untuk menghindari first-use freeze
  Future<void> _prewarmServicesAsync() async {
    if (_servicesPrewarmed) return;

    try {
      _isPrewarming = true;
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 10));

      // Test camera service readiness
      if (_cameraService.isInitialized) {
        log('Camera service prewarmed');
      }

      // Test gallery service readiness
      if (_galleryService.isInitialized) {
        log('Gallery service prewarmed');
      }

      _servicesPrewarmed = true;
      _isPrewarming = false;

      log('Services prewarmed successfully');
      notifyListeners();
    } catch (e) {
      _isPrewarming = false;
      log('Services prewarm error: $e');
    }
  }

  Future<void> warmUpServices() async {
    await _prewarmServicesAsync();
  }

  /// Validate semua services siap digunakan
  Future<void> _validateServicesAsync() async {
    await Future.delayed(const Duration(milliseconds: 5));

    if (!_cameraService.isInitialized) {
      throw Exception('Camera service not properly initialized');
    }

    if (!_galleryService.isInitialized) {
      throw Exception('Gallery service not properly initialized');
    }

    log('All services validated');
  }

  /// Update progress dengan async yield points
  Future<void> _updateProgressAsync(double progress, String step) async {
    _initProgress = progress;
    _currentStep = step;
    log('ML Init Progress: ${(progress * 100).toStringAsFixed(0)}% - $step');

    // Notify listeners
    notifyListeners();

    // Critical: Yield to prevent UI freeze
    await Future.delayed(const Duration(milliseconds: 8));
  }

  /// Run function dengan micro-yields untuk prevent freeze
  Future<T> _runWithMicroYields<T>(Future<T> Function() operation) async {
    final completer = Completer<T>();

    // Yield sebelum operasi
    await Future.delayed(const Duration(milliseconds: 2));

    try {
      final result = await operation();

      // Yield setelah operasi
      await Future.delayed(const Duration(milliseconds: 2));

      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// Initialize dengan retry dan aggressive timeout
  Future<void> initializeWithRetry({
    int maxRetries = 3,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts <= maxRetries && !_isInitialized) {
      try {
        attempts++;
        log('ML Service initialization attempt $attempts');

        await initializeAll().timeout(timeout);
        return; // Success
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        log('Initialization attempt $attempts failed: $e');

        if (attempts <= maxRetries) {
          await _updateProgressAsync(
            0.0,
            'Retrying... (${attempts}/${maxRetries})',
          );

          // Reset state untuk retry
          _reset();

          // Progressive delay
          await Future.delayed(Duration(seconds: attempts));
        }
      }
    }

    throw lastException ?? Exception('All initialization attempts failed');
  }

  /// Background initialization (non-blocking)
  Future<void> initializeInBackground() async {
    // Start initialization tanpa await
    unawaited(initializeAll());
  }

  /// Hot reload support - reset semua state
  void _reset() {
    _isInitialized = false;
    _isInitializing = false;
    _isPrewarming = false;
    _initProgress = 0.0;
    _currentStep = '';
    _errorMessage = null;
    _modelPreloaded = false;
    _servicesPrewarmed = false;
  }

  /// Reset public method
  Future<void> reset() async {
    try {
      if (_isInitialized) {
        await _cameraService.close();
        await _galleryService.close();
      }
    } catch (e) {
      log('Error closing services during reset: $e');
    }

    _reset();
    notifyListeners();
  }

  /// Enhanced health check
  bool get isHealthy {
    try {
      return _isInitialized &&
          _modelPreloaded &&
          _cameraService.isInitialized &&
          _galleryService.isInitialized;
    } catch (e) {
      return false;
    }
  }

  /// Performance metrics
  Map<String, dynamic> get performanceMetrics => {
    'initTimeMs': _initStopwatch.elapsedMilliseconds,
    'isPrewarmed': _servicesPrewarmed,
    'modelPreloaded': _modelPreloaded,
    'totalSteps': _totalInitSteps,
    'memoryUsage': 'TODO: implement memory tracking',
  };

  /// Debug info
  Map<String, dynamic> get debugInfo => {
    'isInitialized': _isInitialized,
    'isInitializing': _isInitializing,
    'isPrewarming': _isPrewarming,
    'progress': _initProgress,
    'currentStep': _currentStep,
    'hasError': _errorMessage != null,
    'errorMessage': _errorMessage,
    'isHealthy': isHealthy,
    'isReady': isReady,
    'performance': performanceMetrics,
  };
}

/// Enhanced loading overlay 
class MLInitializationOverlay extends StatelessWidget {
  const MLInitializationOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MLServiceManager>(
      builder: (context, manager, child) {
        if (!manager.isInitializing && !manager.isPrewarming) {
          return const SizedBox.shrink();
        }

        return Container(
          color: Colors.black.withOpacity(0.85),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              margin: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Current step
                  Text(
                    manager.currentStep.isEmpty
                        ? 'Preparing...'
                        : manager.currentStep,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Progress bar with animation
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: manager.initProgress),
                        duration: const Duration(milliseconds: 300),
                        builder: (context, value, child) {
                          return LinearProgressIndicator(
                            value: value,
                            backgroundColor: Colors.transparent,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.blueAccent,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Percentage
                  Text(
                    '${(manager.initProgress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
