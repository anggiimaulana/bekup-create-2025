import 'dart:developer';
import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:food_recognition_app/service/image_classification_service.dart';

class ImageClassificationViewmodel extends ChangeNotifier {
  final ImageClassificationService _service;
  bool _isInitialized = false;

  ImageClassificationViewmodel(this._service);

  // State untuk menyimpan hasil klasifikasi
  Map<String, double> _classifications = {};

  // Getter untuk mendapatkan top 3 hasil klasifikasi
  Map<String, double> get classifications => Map.fromEntries(
    (_classifications.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value))) // Sort descending
        .take(3),
  );

  bool get isInitialized => _isInitialized;

  // Initialize service
  Future<void> initialize() async {
    try {
      log('Initializing ImageClassificationViewmodel...');
      await _service.initHelper();
      _isInitialized = true;
      log('ImageClassificationViewmodel initialized successfully');
    } catch (e) {
      log('Error initializing ImageClassificationViewmodel: $e');
      rethrow;
    }
  }

  // Run inference process
  Future<void> runClassification(CameraImage cameraImage) async {
    if (!_isInitialized) return;

    try {
      final results = await _service.inferenceCameraFrame(cameraImage);

      // Filter hasil dengan confidence > 0.1 (10%)
      _classifications = Map.fromEntries(
        results.entries.where((entry) => entry.value > 0.1),
      );

      notifyListeners();
    } catch (e) {
      log('Error during classification: $e');
      // Don't rethrow, just log the error to prevent UI crashes
    }
  }

  // Close service
  Future<void> close() async {
    try {
      await _service.close();
      log('ImageClassificationViewmodel closed');
    } catch (e) {
      log('Error closing ImageClassificationViewmodel: $e');
    }
  }
}
