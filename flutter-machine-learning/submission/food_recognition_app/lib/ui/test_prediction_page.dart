import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:food_recognition_app/controller/gallery_prediction_controller.dart';
import 'package:food_recognition_app/utils/debug_helper.dart';

class TestPredictionPage extends StatefulWidget {
  const TestPredictionPage({super.key});

  @override
  State<TestPredictionPage> createState() => _TestPredictionPageState();
}

class _TestPredictionPageState extends State<TestPredictionPage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isTestingService = false;
  Map<String, dynamic>? _serviceStatus;
  Map<String, dynamic>? _predictionStats;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'ML Prediction Test',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<GalleryPredictionController>(
        builder: (context, controller, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Service Status Card
                _buildServiceStatusCard(controller),
                const SizedBox(height: 16),

                // Image Selection Card
                _buildImageSelectionCard(),
                const SizedBox(height: 16),

                // Test Controls Card
                _buildTestControlsCard(controller),
                const SizedBox(height: 16),

                // Prediction Results Card
                if (controller.hasPredictions)
                  _buildPredictionResultsCard(controller),
                const SizedBox(height: 16),

                // Debug Information Card
                _buildDebugInfoCard(controller),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceStatusCard(GalleryPredictionController controller) {
    final serviceStatus = controller.serviceStatus;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  serviceStatus['isInitialized']
                      ? Icons.check_circle
                      : Icons.error,
                  color: serviceStatus['isInitialized']
                      ? Colors.green
                      : Colors.red,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Service Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatusItem('Initialized', serviceStatus['isInitialized']),
            _buildStatusItem('Loading', serviceStatus['isLoading']),
            _buildStatusItem('Has Error', serviceStatus['hasError']),
            _buildStatusItem(
              'Has Predictions',
              serviceStatus['hasPredictions'],
            ),
            if (serviceStatus['errorMessage'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Error: ${serviceStatus['errorMessage']}',
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, bool status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            status ? Icons.check : Icons.close,
            size: 16,
            color: status ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildImageSelectionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test Image',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_selectedImage != null) ...[
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_selectedImage!, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Path: ${_selectedImage!.path}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              FutureBuilder<int>(
                future: _selectedImage!.length(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      'Size: ${(snapshot.data! / 1024).toStringAsFixed(1)} KB',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ] else
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(child: Text('No image selected')),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImageFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImageFromCamera,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestControlsCard(GalleryPredictionController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test Controls',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isTestingService
                        ? null
                        : () => _testService(controller),
                    icon: _isTestingService
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.build),
                    label: const Text('Test Service'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: controller.isLoading || _selectedImage == null
                        ? null
                        : () => _runPrediction(controller),
                    icon: controller.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.analytics),
                    label: const Text('Predict'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _clearResults(controller),
                icon: const Icon(Icons.clear),
                label: const Text('Clear Results'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionResultsCard(GalleryPredictionController controller) {
    final predictions = controller.getFormattedTopPredictions(topN: 10);
    final stats = controller.predictionStats;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Prediction Results',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Statistics
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Predictions: ${stats['totalPredictions']}'),
                      Text(
                        'Avg Confidence: ${(stats['avgConfidence'] * 100).toStringAsFixed(1)}%',
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Max: ${(stats['maxConfidence'] * 100).toStringAsFixed(1)}%',
                      ),
                      Text(
                        'Min: ${(stats['minConfidence'] * 100).toStringAsFixed(1)}%',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Top predictions
            ...predictions.entries.take(5).map((entry) {
              final confidence =
                  double.tryParse(entry.value.replaceAll('%', '')) ?? 0;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _getConfidenceColor(confidence),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            entry.value,
                            style: TextStyle(
                              color: _getConfidenceColor(confidence),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugInfoCard(GalleryPredictionController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Debug Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_serviceStatus != null) ...[
              const Text(
                'Service Status:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _serviceStatus.toString(),
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
            ],
            if (_predictionStats != null) ...[
              const Text(
                'Prediction Stats:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _predictionStats.toString(),
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 80) return Colors.green;
    if (confidence >= 60) return Colors.orange;
    if (confidence >= 40) return Colors.deepOrange;
    return Colors.red;
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        DebugHelper.logFileInfo(_selectedImage, prefix: 'Selected Image');
      }
    } catch (e) {
      DebugHelper.logError('Image selection from gallery', e);
      _showErrorSnackBar('Failed to pick image from gallery: $e');
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        DebugHelper.logFileInfo(_selectedImage, prefix: 'Camera Image');
      }
    } catch (e) {
      DebugHelper.logError('Image capture from camera', e);
      _showErrorSnackBar('Failed to capture image: $e');
    }
  }

  Future<void> _testService(GalleryPredictionController controller) async {
    setState(() {
      _isTestingService = true;
    });

    try {
      await controller.initialize();
      final status = controller.serviceStatus;
      setState(() {
        _serviceStatus = status;
      });
      _showSuccessSnackBar('Service test completed successfully');
    } catch (e) {
      DebugHelper.logError('Service test', e);
      _showErrorSnackBar('Service test failed: $e');
    } finally {
      setState(() {
        _isTestingService = false;
      });
    }
  }

  Future<void> _runPrediction(GalleryPredictionController controller) async {
    if (_selectedImage == null) {
      _showErrorSnackBar('Please select an image first');
      return;
    }

    try {
      DebugHelper.logFileInfo(_selectedImage, prefix: 'Prediction Input');

      await controller.predictFromFile(_selectedImage!);

      final stats = controller.predictionStats;
      setState(() {
        _predictionStats = stats;
      });

      DebugHelper.logPredictions(controller.formattedPredictions);
      _showSuccessSnackBar('Prediction completed successfully');
    } catch (e) {
      DebugHelper.logError('Prediction', e);
      _showErrorSnackBar('Prediction failed: $e');
    }
  }

  void _clearResults(GalleryPredictionController controller) {
    controller.clearPredictions();
    setState(() {
      _selectedImage = null;
      _serviceStatus = null;
      _predictionStats = null;
    });
    _showInfoSnackBar('Results cleared');
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
