import 'dart:io';
import 'package:flutter/material.dart';
import 'package:food_recognition_app/controller/home/home_controller.dart';
import 'package:food_recognition_app/controller/ml/ml_service_manager.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Food Recognizer App',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          // ML Service Status Indicator
          Consumer<MLServiceManager>(
            builder: (context, mlManager, child) {
              if (mlManager.isInitialized) {
                return const Padding(
                  padding: EdgeInsets.only(right: 16),
                );
              } else if (mlManager.isInitializing) {
                return const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                );
              } else {
                return const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(Icons.warning, color: Colors.orange),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: const _HomeBody(),
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeController>(
      builder: (context, controller, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header section
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: const Text(
                'Welcome to Food Recognition',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.blueAccent,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),

            // Status message
            _StatusMessage(),

            const SizedBox(height: 32),

            // Image display section
            Expanded(
              child: controller.selectedImage != null
                  ? _ImageDisplaySection(
                      imageFile: controller.selectedImage!,
                      onClearImage: controller.clearSelectedImage,
                    )
                  : _ImageSelectionSection(),
            ),

            // Analysis progress indicator
            if (controller.isLoading) ...[
              const SizedBox(height: 16),
              _AnalysisProgressIndicator(),
            ],

            const SizedBox(height: 32),

            // Action buttons
            if (controller.selectedImage != null) ...[
              // Analyze button
              SizedBox(
                height: 50,
                child: FilledButton.tonal(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.green),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  onPressed: controller.isLoading
                      ? null
                      : () => controller.analyzeSelectedImage(context),
                  child: controller.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.analytics, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "Analyze",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 12),

              // Crop & Analyze button
              SizedBox(
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.blueAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: controller.isLoading
                      ? null
                      : () => controller.goToCroppingPage(context),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.crop, color: Colors.blueAccent),
                      SizedBox(width: 8),
                      Text(
                        "Crop & Analyze",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Camera button
              SizedBox(
                height: 50,
                child: FilledButton.tonal(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.blueAccent),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  onPressed: controller.isLoading
                      ? null
                      : () => controller.goToCameraPage(context),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "Open Camera",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Gallery button
              SizedBox(
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.blueAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: controller.isLoading
                      ? null
                      : () => controller.pickImageFromGallery(),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library, color: Colors.blueAccent),
                      SizedBox(width: 8),
                      Text(
                        "Choose from Gallery",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _StatusMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeController, MLServiceManager>(
      builder: (context, homeController, mlManager, child) {
        String statusText;
        Color statusColor = Colors.grey;

        if (mlManager.isInitializing) {
          statusText = 'Loading AI model... Please wait';
          statusColor = Colors.orange;
        } else if (!mlManager.isInitialized) {
          statusText = 'AI model loading failed - Some features may not work';
          statusColor = Colors.red;
        } else if (homeController.selectedImage != null) {
          statusText = 'Selected image ready for analysis';
          statusColor = Colors.green;
        } else {
          statusText = 'Choose camera or gallery to get started';
          statusColor = Colors.grey;
        }

        return Text(
          statusText,
          style: TextStyle(fontSize: 16, color: statusColor),
          textAlign: TextAlign.center,
        );
      },
    );
  }
}

class _AnalysisProgressIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeController>(
      builder: (context, controller, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Text(
                controller.analysisStatus.isNotEmpty
                    ? controller.analysisStatus
                    : 'Processing...',
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: controller.analysisProgress,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(controller.analysisProgress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ImageSelectionSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.blueAccent.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_photo_alternate, size: 80, color: Colors.blueAccent),
            SizedBox(height: 16),
            Text(
              'Select an image or\nopen camera',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blueAccent,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageDisplaySection extends StatelessWidget {
  final File imageFile;
  final VoidCallback onClearImage;

  const _ImageDisplaySection({
    required this.imageFile,
    required this.onClearImage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.blueAccent.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              imageFile,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Error loading image',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        // Clear button
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onClearImage,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}
