import 'dart:developer';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food_recognition_app/controller/ml/ml_service_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:food_recognition_app/controller/gallery/gallery_prediction_controller.dart';
import 'package:food_recognition_app/ui/result/result_page.dart';
import 'package:food_recognition_app/ui/crop/cropping_page.dart';
import 'package:food_recognition_app/ui/camera/camera_page.dart';

class HomeController extends ChangeNotifier {
  GalleryPredictionController _galleryController;

  // State variables
  File? _selectedImage;
  bool _isLoading = false;
  String? _errorMessage;
  String _analysisStatus = '';
  double _analysisProgress = 0.0;
  bool _isAnalyzing = false;

  // Performance tracking
  final Stopwatch _analysisStopwatch = Stopwatch();

  // Image picker instance
  final ImagePicker _picker = ImagePicker();

  // Analysis cancellation
  bool _analysisCompleted = false;

  // Constructor
  HomeController(this._galleryController);

  // Getters
  File? get selectedImage => _selectedImage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get analysisStatus => _analysisStatus;
  double get analysisProgress => _analysisProgress;
  bool get isAnalyzing => _isAnalyzing;

  // Update gallery controller (called by provider)
  void updateGalleryController(GalleryPredictionController newController) {
    if (_galleryController != newController) {
      _galleryController = newController;
    }
  }

  // Check if we have predictions from gallery controller
  bool get hasPredictions => _galleryController.hasPredictions;

  // Get predictions from gallery controller
  Map<String, String> get predictions =>
      _galleryController.formattedPredictions;

  // Pick image from gallery dengan optimization
  Future<void> pickImageFromGallery() async {
    try {
      _setLoading(true);
      _clearError();
      _updateAnalysisStatus('Opening gallery...');

      log('Picking image from gallery...');

      // Yield untuk prevent freeze
      await Future.delayed(const Duration(milliseconds: 10));

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      // Yield after picker
      await Future.delayed(const Duration(milliseconds: 5));

      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
        log('Image selected from gallery: ${_selectedImage!.path}');

        // Clear any previous predictions (async)
        await _clearPredictionsAsync();
        _updateAnalysisStatus('Image selected');

        notifyListeners();
      } else {
        log('No image selected from gallery');
        _updateAnalysisStatus('');
      }
    } catch (e) {
      final errorMsg = 'Failed to pick image from gallery: $e';
      _setError(errorMsg);
      log('Error picking image from gallery: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// ZERO-FREEZE ANALYSIS - The main optimization!
  Future<void> analyzeSelectedImage(BuildContext context) async {
    if (_selectedImage == null) {
      _setError('No image selected');
      return;
    }

    if (_isAnalyzing) {
      log('Analysis already in progress, skipping...');
      return;
    }

    _analysisStopwatch.start();
    _analysisCompleted = false;

    try {
      _setLoading(true);
      _isAnalyzing = true;
      _clearError();
      _updateAnalysisStatus('Preparing analysis...', 0.0);

      log('=== Starting ZERO-FREEZE Image Analysis ===');
      log('Selected image path: ${_selectedImage!.path}');

      // Step 1: Lightweight file validation (5ms max)
      await _quickValidateImageFileAsync(_selectedImage!);
      if (_analysisCompleted) return;
      await _updateAnalysisStatusAsync('Image validated ✓', 0.1);

      // Check context early
      if (!context.mounted) {
        log('Context not mounted, aborting analysis');
        return;
      }

      // Step 2: ML Services readiness check (non-blocking)
      final mlManager = context.read<MLServiceManager>();
      await _ensureMLServicesReadyAsync(mlManager, context);
      if (_analysisCompleted) return;
      await _updateAnalysisStatusAsync('AI model ready', 0.25);

      // Step 3: Gallery controller preparation (with yielding)
      await _ensureGalleryControllerReadyAsync();
      if (_analysisCompleted) return;
      await _updateAnalysisStatusAsync('Analyzer ready', 0.25);

      // Step 4: Run prediction with chunked processing
      await _updateAnalysisStatusAsync('Processing image...', 0.25);
      await _runPredictionWithChunks();
      if (_analysisCompleted) return;

      // Step 5: Process results
      await _updateAnalysisStatusAsync('Processing results...', 0.25);
      await _processAnalysisResultsAsync();
      if (_analysisCompleted) return;

      // Step 6: Navigation preparation
      await _updateAnalysisStatusAsync('Preparing results...', 0.3);
      final predictions = _galleryController.formattedPredictions;

      if (predictions.isEmpty) {
        throw Exception(
          'No predictions generated. The AI may not recognize this image type.',
        );
      }

      await _updateAnalysisStatusAsync('Analysis complete!', 1.0);

      // Brief success indication
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate if context still mounted
      if (!context.mounted) {
        log('Context no longer mounted, skipping navigation');
        return;
      }

      await _navigateToResultsAsync(context, predictions);

      _analysisStopwatch.stop();
      log(
        '=== Analysis completed in ${_analysisStopwatch.elapsedMilliseconds}ms ===',
      );
    } catch (e, stackTrace) {
      _analysisStopwatch.stop();
      final errorMsg = 'Analysis failed: $e';
      _setError(errorMsg);

      log('=== Analysis Error ===');
      log('Error: $e');
      log('Time elapsed: ${_analysisStopwatch.elapsedMilliseconds}ms');
      log('Stack trace: $stackTrace');

      if (context.mounted) {
        _showErrorSnackBar(context, errorMsg);
      }
    } finally {
      _analysisCompleted = true;
      _isAnalyzing = false;
      _setLoading(false);
      _updateAnalysisStatus('');
    }
  }

  /// Ensure ML services ready dengan smooth waiting
  Future<void> _ensureMLServicesReadyAsync(
    MLServiceManager mlManager,
    BuildContext context,
  ) async {
    if (mlManager.isReady) {
      log('ML services already ready');
      return;
    }

    if (mlManager.isInitializing) {
      log('Waiting for ML services initialization...');

      // Smooth progress tracking tanpa freeze
      final completer = Completer<void>();
      late Timer progressTimer;

      progressTimer = Timer.periodic(const Duration(milliseconds: 200), (
        timer,
      ) {
        if (_analysisCompleted || !context.mounted) {
          timer.cancel();
          if (!completer.isCompleted) completer.complete();
          return;
        }

        if (mlManager.isReady) {
          timer.cancel();
          if (!completer.isCompleted) completer.complete();
          return;
        }

        // Update progress smoothly
        final mlProgress = mlManager.initProgress;
        final adjustedProgress = 0.1 + (mlProgress * 0.2);
        _updateAnalysisStatus(
          'AI Loading: ${mlManager.currentStep}',
          adjustedProgress,
        );

        if (mlManager.errorMessage != null) {
          timer.cancel();
          if (!completer.isCompleted) {
            completer.completeError(Exception(mlManager.errorMessage));
          }
        }
      });

      // Timeout protection
      Timer(const Duration(seconds: 25), () {
        progressTimer.cancel();
        if (!completer.isCompleted) {
          completer.completeError(
            TimeoutException('ML services initialization timeout'),
          );
        }
      });

      await completer.future;
    }

    if (!mlManager.isReady) {
      throw Exception('ML services not ready: ${mlManager.errorMessage}');
    }
  }

  /// Ensure gallery controller ready (lightweight)
  Future<void> _ensureGalleryControllerReadyAsync() async {
    // Yield point
    await Future.delayed(const Duration(milliseconds: 5));

    if (!_galleryController.isInitialized) {
      await _galleryController.initialize();
    }

    // Yield after initialization
    await Future.delayed(const Duration(milliseconds: 5));
  }

  /// Run prediction dengan chunking untuk prevent freeze
  Future<void> _runPredictionWithChunks() async {
    const int totalChunks = 5;

    for (int i = 0; i < totalChunks; i++) {
      if (_analysisCompleted) return;

      // Update progress per chunk
      final chunkProgress = 0.5 + (i / totalChunks * 0.3); 

      switch (i) {
        case 0:
          await _updateAnalysisStatusAsync(
            'Loading image data...',
            chunkProgress,
          );
          await Future.delayed(const Duration(milliseconds: 50)); 
          break;
        case 1:
          await _updateAnalysisStatusAsync(
            'Preprocessing image...',
            chunkProgress,
          );
          await Future.delayed(const Duration(milliseconds: 50)); 
          break;
        case 2:
          await _updateAnalysisStatusAsync(
            'Running AI inference...',
            chunkProgress,
          );
          // The actual heavy operation here
          await _galleryController.predictFromFile(_selectedImage!);
          break;
        case 3:
          await _updateAnalysisStatusAsync('Post-processing...', chunkProgress);
          await Future.delayed(const Duration(milliseconds: 30)); // Yield
          break;
        case 4:
          await _updateAnalysisStatusAsync(
            'Finalizing results...',
            chunkProgress,
          );
          await Future.delayed(const Duration(milliseconds: 20)); // Yield
          break;
      }
    }
  }

  /// Process analysis results dengan micro-yields
  Future<void> _processAnalysisResultsAsync() async {
    // Yield sebelum processing
    await Future.delayed(const Duration(milliseconds: 10));

    // Validate results
    final predictions = _galleryController.formattedPredictions;
    log('Analysis results: ${predictions.length} predictions');

    // Yield setelah validation
    await Future.delayed(const Duration(milliseconds: 10));
  }

  /// Navigate to results dengan error handling
  Future<void> _navigateToResultsAsync(
    BuildContext context,
    Map<String, String> predictions,
  ) async {
    try {
      // Yield sebelum navigation
      await Future.delayed(const Duration(milliseconds: 20));

      log('Navigating to results with ${predictions.length} predictions');

      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) =>
              ResultPage(imageFile: _selectedImage, predictions: predictions),
        ),
      );

      log('Navigation completed with result: $result');
    } catch (navError) {
      log('Navigation error: $navError');
      if (context.mounted) {
        _showErrorSnackBar(
          context,
          'Results ready but navigation failed: $navError',
        );
      }
    }
  }

  /// Quick file validation (ultra lightweight)
  Future<void> _quickValidateImageFileAsync(File imageFile) async {
    // Yield first
    await Future.delayed(const Duration(milliseconds: 2));

    if (!await imageFile.exists()) {
      throw Exception('Image file not found');
    }

    final fileSize = await imageFile.length();
    log('Image file size: ${_formatFileSize(fileSize)}');

    if (fileSize == 0) {
      throw Exception('Image file is empty');
    }

    // Size limit check (15MB)
    if (fileSize > 15 * 1024 * 1024) {
      throw Exception('Image too large (max 15MB)');
    }
  }

  /// Update analysis status dengan async yields
  Future<void> _updateAnalysisStatusAsync(
    String status, [
    double? progress,
  ]) async {
    _analysisStatus = status;
    if (progress != null) {
      _analysisProgress = progress.clamp(0.0, 1.0);
    }

    // Critical: Notify listeners dan yield untuk prevent freeze
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 3));
  }

  /// Clear predictions secara async
  Future<void> _clearPredictionsAsync() async {
    await Future.delayed(const Duration(milliseconds: 2));
    _galleryController.clearPredictions();
    await Future.delayed(const Duration(milliseconds: 2));
  }

  /// Format file size helper
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // Go to cropping page (optimized)
  void goToCroppingPage(BuildContext context) {
    if (_selectedImage == null) {
      _setError('No image selected');
      return;
    }

    try {
      log('Navigating to cropping page');

      if (!context.mounted) {
        log('Context not mounted, aborting navigation to crop page');
        return;
      }

      // Navigate dengan micro delay untuk smooth transition
      Future.delayed(const Duration(milliseconds: 10), () {
        if (context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CroppingPage(
                imageFile: _selectedImage!,
                predictionController: _galleryController,
              ),
            ),
          );
        }
      });
    } catch (e) {
      final errorMsg = 'Failed to open cropping page: $e';
      _setError(errorMsg);
      log('Error navigating to cropping page: $e');

      if (context.mounted) {
        _showErrorSnackBar(context, errorMsg);
      }
    }
  }

  // Go to camera page (optimized)
  void goToCameraPage(BuildContext context) {
    try {
      log('Navigating to camera page');

      if (!context.mounted) {
        log('Context not mounted, aborting navigation to camera page');
        return;
      }

      // Navigate dengan micro delay untuk smooth transition
      Future.delayed(const Duration(milliseconds: 10), () {
        if (context.mounted) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const CameraPage()));
        }
      });
    } catch (e) {
      final errorMsg = 'Failed to open camera: $e';
      _setError(errorMsg);
      log('Error navigating to camera page: $e');

      if (context.mounted) {
        _showErrorSnackBar(context, errorMsg);
      }
    }
  }

  // Helper method to show error snackbar (optimized)
  void _showErrorSnackBar(BuildContext context, String message) {
    try {
      // Delay untuk ensure context ready
      Future.delayed(const Duration(milliseconds: 100), () {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
      });
    } catch (e) {
      log('Failed to show snackbar: $e');
    }
  }

  // Clear selected image (optimized)
  void clearSelectedImage() {
    log('Clearing selected image');
    _selectedImage = null;

    // Clear predictions async untuk prevent micro-freeze
    Future.delayed(const Duration(milliseconds: 5), () {
      _galleryController.clearPredictions();
    });

    _clearError();
    _updateAnalysisStatus('');
    notifyListeners();
  }

  // Set selected image (optimized untuk camera capture)
  void setSelectedImage(File? imageFile) {
    log('Setting selected image: ${imageFile?.path}');
    _selectedImage = imageFile;

    if (imageFile == null) {
      // Clear predictions async
      Future.delayed(const Duration(milliseconds: 5), () {
        _galleryController.clearPredictions();
      });
    }

    _clearError();
    _updateAnalysisStatus('');
    notifyListeners();
  }

  // Helper methods (optimized)
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

  void _updateAnalysisStatus(String status, [double? progress]) {
    _analysisStatus = status;
    if (progress != null) {
      _analysisProgress = progress.clamp(0.0, 1.0);
    }
    notifyListeners();
  }

  // Reset controller state (enhanced)
  void reset() {
    _selectedImage = null;
    _isLoading = false;
    _isAnalyzing = false;
    _analysisProgress = 0.0;
    _analysisStatus = '';
    _analysisCompleted = false;
    _clearError();

    // Reset gallery controller async
    Future.delayed(const Duration(milliseconds: 5), () {
      _galleryController.reset();
    });

    notifyListeners();
  }

  // Check if image is selected
  bool get hasImage => _selectedImage != null;

  // Get image file size (async optimized)
  Future<String> getImageFileSize() async {
    if (_selectedImage == null) return 'N/A';

    try {
      final size = await _selectedImage!.length();
      return _formatFileSize(size);
    } catch (e) {
      log('Error getting file size: $e');
      return 'N/A';
    }
  }

  // Analysis progress info untuk debugging
  Map<String, dynamic> get analysisDebugInfo => {
    'isAnalyzing': _isAnalyzing,
    'analysisProgress': _analysisProgress,
    'analysisStatus': _analysisStatus,
    'analysisCompleted': _analysisCompleted,
    'elapsedMs': _analysisStopwatch.elapsedMilliseconds,
    'hasImage': hasImage,
    'hasPredictions': hasPredictions,
  };

  @override
  void dispose() {
    _analysisCompleted = true;
    _selectedImage = null;
    super.dispose();
  }
}
