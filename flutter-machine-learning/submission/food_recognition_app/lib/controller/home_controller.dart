import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:food_recognition_app/ui/camera_page.dart';
import 'package:food_recognition_app/ui/result_page.dart';
import 'package:food_recognition_app/ui/cropping_page.dart';

class HomeController extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isLoading = false;

  File? get selectedImage => _selectedImage;
  bool get isLoading => _isLoading;

  // Pilih gambar dari galeri dengan kualitas optimal
  Future<void> pickImageFromGallery() async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      notifyListeners();

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90, // Kualitas bagus tapi tidak terlalu besar
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        _selectedImage = File(image.path);
        debugPrint('Image selected from gallery: ${image.path}');
      }
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Buka kamera - simplified
  Future<void> goToCameraPage(BuildContext context) async {
    if (_isLoading || !context.mounted) return;

    try {
      _isLoading = true;
      notifyListeners();

      debugPrint('Navigating to camera page...');

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CameraPage(),
          settings: const RouteSettings(name: '/camera'),
        ),
      );

      debugPrint('Returned from camera page');
    } catch (e) {
      debugPrint('Error navigating to camera: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open camera: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _isLoading = false;
      if (context.mounted) {
        notifyListeners();
      }
    }
  }

  // Navigate ke result page
  Future<void> goToResultPage(BuildContext context) async {
    if (_isLoading || !context.mounted) return;

    try {
      _isLoading = true;
      notifyListeners();

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ResultPage(),
          settings: const RouteSettings(name: '/result'),
        ),
      );
    } catch (e) {
      debugPrint('Error navigating to result: $e');
    } finally {
      _isLoading = false;
      if (context.mounted) {
        notifyListeners();
      }
    }
  }

  // Navigate ke halaman cropping
  Future<void> goToCroppingPage(BuildContext context) async {
    if (_selectedImage == null || _isLoading || !context.mounted) return;

    try {
      _isLoading = true;
      notifyListeners();

      final croppedImage = await Navigator.push<File?>(
        context,
        MaterialPageRoute(
          builder: (context) => CroppingPage(imageFile: _selectedImage!),
          settings: const RouteSettings(name: '/cropping'),
        ),
      );

      if (croppedImage != null) {
        _selectedImage = croppedImage;
        debugPrint('Image cropped successfully: ${croppedImage.path}');
      }
    } catch (e) {
      debugPrint('Error navigating to cropping: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to open image cropping'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _isLoading = false;
      if (context.mounted) {
        notifyListeners();
      }
    }
  }

  // Analyze selected image - simplified
  Future<void> analyzeSelectedImage() async {
    if (_selectedImage == null || _isLoading) return;

    try {
      _isLoading = true;
      notifyListeners();

      debugPrint('Starting image analysis: ${_selectedImage!.path}');

      // TODO: Implement actual ML analysis here
      // Simulate processing time
      await Future.delayed(const Duration(milliseconds: 500));

      debugPrint('Image analysis completed');
    } catch (e) {
      debugPrint('Error analyzing image: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear selected image
  void clearSelectedImage() {
    if (_isLoading) return;

    _selectedImage = null;
    debugPrint('Selected image cleared');
    notifyListeners();
  }

  // Reset controller state
  void reset() {
    _selectedImage = null;
    _isLoading = false;
    debugPrint('HomeController reset');
    notifyListeners();
  }

  // Check if image file exists and is valid
  bool get hasValidImage {
    if (_selectedImage == null) return false;

    try {
      return _selectedImage!.existsSync() && _selectedImage!.lengthSync() > 0;
    } catch (e) {
      debugPrint('Error checking image validity: $e');
      return false;
    }
  }

  // Get image file size in MB
  double get imageFileSizeInMB {
    if (_selectedImage == null || !hasValidImage) return 0.0;

    try {
      final bytes = _selectedImage!.lengthSync();
      return bytes / (1024 * 1024);
    } catch (e) {
      debugPrint('Error getting image size: $e');
      return 0.0;
    }
  }

  @override
  void dispose() {
    debugPrint('HomeController disposed');
    super.dispose();
  }
}
