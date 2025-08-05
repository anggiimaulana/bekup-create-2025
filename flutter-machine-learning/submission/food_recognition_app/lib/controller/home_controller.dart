import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:food_recognition_app/controller/gallery_prediction_controller.dart';
import 'package:food_recognition_app/ui/result_page.dart';
import 'package:food_recognition_app/ui/cropping_page.dart';
import 'package:food_recognition_app/ui/camera_page.dart';

class HomeController extends ChangeNotifier {
  GalleryPredictionController _galleryController;

  // State variables
  File? _selectedImage;
  bool _isLoading = false;
  String? _errorMessage;

  // Image picker instance
  final ImagePicker _picker = ImagePicker();

  // Constructor
  HomeController(this._galleryController);

  // Getters
  File? get selectedImage => _selectedImage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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

  // Pick image from gallery
  Future<void> pickImageFromGallery() async {
    try {
      _setLoading(true);
      _clearError();

      log('Picking image from gallery...');

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
        log('Image selected from gallery: ${_selectedImage!.path}');

        // Clear any previous predictions
        _galleryController.clearPredictions();

        notifyListeners();
      } else {
        log('No image selected from gallery');
      }
    } catch (e) {
      final errorMsg = 'Failed to pick image from gallery: $e';
      _setError(errorMsg);
      log('Error picking image from gallery: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Analyze selected image
  Future<void> analyzeSelectedImage(BuildContext context) async {
    if (_selectedImage == null) {
      _setError('No image selected');
      return;
    }

    try {
      _setLoading(true);
      _clearError();

      log('=== Starting Image Analysis ===');
      log('Selected image path: ${_selectedImage!.path}');

      // Verify file exists and is readable
      if (!await _selectedImage!.exists()) {
        throw Exception('Selected image file does not exist');
      }

      final fileSize = await _selectedImage!.length();
      log('Image file size: $fileSize bytes');

      if (fileSize == 0) {
        throw Exception('Selected image file is empty');
      }

      // Check if context is still mounted before proceeding
      if (!context.mounted) {
        log('Context not mounted, aborting analysis');
        return;
      }

      // Initialize gallery controller if needed
      log(
        'Gallery controller initialized: ${_galleryController.isInitialized}',
      );
      if (!_galleryController.isInitialized) {
        log('Initializing gallery prediction controller...');
        await _galleryController.initialize();
        log('Gallery controller initialization complete');
      }

      // Run prediction
      log('Running prediction on image...');
      await _galleryController.predictFromFile(_selectedImage!);
      log('Prediction completed');

      // Check predictions
      final predictions = _galleryController.formattedPredictions;
      log('Predictions received: ${predictions.length} items');

      if (predictions.isEmpty) {
        log('ERROR: No predictions returned from model');
        throw Exception(
          'No predictions could be generated for this image. The model may not recognize this type of image.',
        );
      }

      // Log top predictions for debugging
      log('Top predictions:');
      predictions.entries.take(3).forEach((entry) {
        log('  ${entry.key}: ${entry.value}');
      });

      // Navigate to result page if context is still mounted
      if (!context.mounted) {
        log('Context no longer mounted, skipping navigation');
        return;
      }

      log('Navigating to result page...');

      try {
        final result = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (context) {
              log('Building ResultPage with ${predictions.length} predictions');
              return ResultPage(
                imageFile: _selectedImage,
                predictions: predictions,
              );
            },
          ),
        );
        log('Navigation completed with result: $result');
      } catch (navError) {
        log('Navigation error: $navError');
        // Don't throw here, as the analysis was successful
        if (context.mounted) {
          _showErrorSnackBar(
            context,
            'Analysis completed but failed to show results: $navError',
          );
        }
      }

      log('Image analysis completed successfully');
    } catch (e, stackTrace) {
      final errorMsg = 'Failed to analyze image: $e';
      _setError(errorMsg);
      log('=== Analysis Error ===');
      log('Error: $e');
      log('Stack trace: $stackTrace');

      // Show error message to user if context is still mounted
      if (context.mounted) {
        _showErrorSnackBar(context, errorMsg);
      }
    } finally {
      _setLoading(false);
      log('=== Analysis Complete ===');
    }
  }

  // Go to cropping page
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

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CroppingPage(
            imageFile: _selectedImage!,
            predictionController: _galleryController,
          ),
        ),
      );
    } catch (e) {
      final errorMsg = 'Failed to open cropping page: $e';
      _setError(errorMsg);
      log('Error navigating to cropping page: $e');

      if (context.mounted) {
        _showErrorSnackBar(context, errorMsg);
      }
    }
  }

  // Go to camera page
  void goToCameraPage(BuildContext context) {
    try {
      log('Navigating to camera page');

      if (!context.mounted) {
        log('Context not mounted, aborting navigation to camera page');
        return;
      }

      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const CameraPage()));
    } catch (e) {
      final errorMsg = 'Failed to open camera: $e';
      _setError(errorMsg);
      log('Error navigating to camera page: $e');

      if (context.mounted) {
        _showErrorSnackBar(context, errorMsg);
      }
    }
  }

  // Helper method to show error snackbar
  void _showErrorSnackBar(BuildContext context, String message) {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    } catch (e) {
      log('Failed to show snackbar: $e');
    }
  }

  // Clear selected image
  void clearSelectedImage() {
    log('Clearing selected image');
    _selectedImage = null;
    _galleryController.clearPredictions();
    _clearError();
    notifyListeners();
  }

  // Set selected image (for camera capture result)
  void setSelectedImage(File? imageFile) {
    log('Setting selected image: ${imageFile?.path}');
    _selectedImage = imageFile;
    if (imageFile == null) {
      _galleryController.clearPredictions();
    }
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

  // Reset controller state
  void reset() {
    _selectedImage = null;
    _isLoading = false;
    _clearError();
    _galleryController.reset();
    notifyListeners();
  }

  // Check if image is selected
  bool get hasImage => _selectedImage != null;

  // Get image file size
  Future<String> getImageFileSize() async {
    if (_selectedImage == null) return 'N/A';

    try {
      final size = await _selectedImage!.length();
      if (size < 1024) {
        return '$size B';
      } else if (size < 1024 * 1024) {
        return '${(size / 1024).toStringAsFixed(1)} KB';
      } else {
        return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
    } catch (e) {
      return 'N/A';
    }
  }

  // Test if all services are working
  Future<bool> testServices() async {
    try {
      log('Testing services...');

      if (!_galleryController.isInitialized) {
        await _galleryController.initialize();
      }

      log('Services test passed');
      return true;
    } catch (e) {
      log('Services test failed: $e');
      return false;
    }
  }

  @override
  void dispose() {
    // Clean up resources
    _selectedImage = null;
    super.dispose();
  }
}
