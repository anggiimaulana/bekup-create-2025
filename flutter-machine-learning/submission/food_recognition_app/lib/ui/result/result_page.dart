import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:food_recognition_app/service/gemini_service.dart';
import 'package:food_recognition_app/service/meal_db_service.dart';
import 'package:provider/provider.dart';
import '../../widget/classification_item.dart';
import '../../controller/meal/meal_detail_controller.dart';
import '../detail/meal_detail_page.dart';

class ResultPage extends StatelessWidget {
  final File? imageFile;
  final Map<String, String> predictions;

  const ResultPage({super.key, this.imageFile, this.predictions = const {}});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blueAccent,
        title: const Text('Result Page', style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: SafeArea(
        child: _ResultBody(imageFile: imageFile, predictions: predictions),
      ),
    );
  }
}

class _ResultBody extends StatefulWidget {
  final File? imageFile;
  final Map<String, String> predictions;

  const _ResultBody({this.imageFile, this.predictions = const {}});

  @override
  State<_ResultBody> createState() => _ResultBodyState();
}

class _ResultBodyState extends State<_ResultBody> {
  @override
  void initState() {
    super.initState();
    // Log the received data for debugging
    debugPrint('ResultPage initialized with:');
    debugPrint('Image file: ${widget.imageFile?.path}');
    debugPrint('Predictions count: ${widget.predictions.length}');
    widget.predictions.forEach((key, value) {
      debugPrint('  $key: $value');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Image display section
        Container(
          height: 250, // Fixed height untuk image
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.blueAccent.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _buildImageWidget(),
          ),
        ),

        // Scrollable Results section
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header (Fixed)
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: const Text(
                    'Prediction Results',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),

                // Scrollable content
                Expanded(
                  child: widget.predictions.isNotEmpty
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              // Prediction results list (dynamic height)
                              _buildResultsList(),

                              const SizedBox(height: 20),

                              // Nutrition info section
                              _buildNutritionSection(),

                              const SizedBox(height: 20),

                              // Reference section
                              _buildReferenceSection(),

                              const SizedBox(height: 20),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildEmptyState(),
                        ),
                ),

                // Action buttons (Fixed at bottom)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildActionButtons(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageWidget() {
    if (widget.imageFile != null) {
      return Image.file(
        widget.imageFile!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading image: $error');
          return _buildErrorImageWidget('Error loading image');
        },
      );
    } else {
      return _buildErrorImageWidget('No image available');
    }
  }

  Widget _buildErrorImageWidget(String message) {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.imageFile != null
                ? Icons.error_outline
                : Icons.image_not_supported,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    final sortedPredictions = widget.predictions.entries.toList();

    return Container(
      // Removed fixed height - now dynamic
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: sortedPredictions.asMap().entries.map((entry) {
          final prediction = entry.value;

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            margin: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                // Classification item
                Expanded(
                  child: ClassificationItem(
                    item: prediction.key,
                    value: prediction.value,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNutritionSection() {
    final topPrediction = widget.predictions.entries.first;
    final foodName = topPrediction.key;

    return FutureBuilder<String>(
      future: GeminiService().generateNutrition(foodName),
      builder: (context, snapshot) {
        Widget nutritionInfo;

        if (snapshot.connectionState == ConnectionState.waiting) {
          nutritionInfo = const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        } else if (snapshot.hasError) {
          nutritionInfo = Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Failed to load nutrition info.',
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        } else {
          // Parse JSON response
          try {
            final parsed = json.decode(snapshot.data!);
            final nutritionList = parsed['nutrition'] as List<dynamic>;
            final nutrition = nutritionList.isNotEmpty
                ? nutritionList[0]
                : null;

            if (nutrition != null) {
              nutritionInfo = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    '• Calories: ${nutrition["calories"]} kcal',
                    style: _nutritionStyle(),
                  ),
                  Text(
                    '• Carbs: ${nutrition["carbs"]} g',
                    style: _nutritionStyle(),
                  ),
                  Text(
                    '• Protein: ${nutrition["protein"]} g',
                    style: _nutritionStyle(),
                  ),
                  Text(
                    '• Fat: ${nutrition["fat"]} g',
                    style: _nutritionStyle(),
                  ),
                  Text(
                    '• Fiber: ${nutrition["fiber"]} g',
                    style: _nutritionStyle(),
                  ),
                ],
              );
            } else {
              nutritionInfo = const Text(
                'Nutrition info not found.',
                style: TextStyle(color: Colors.white70),
              );
            }
          } catch (e) {
            nutritionInfo = const Text(
              'Error parsing nutrition data.',
              style: TextStyle(color: Colors.redAccent),
            );
          }
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Text(
                    'Nutrition Info (per serving):',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              nutritionInfo,
            ],
          ),
        );
      },
    );
  }

  Widget _buildReferenceSection() {
    final topPrediction = widget.predictions.entries.first;
    final foodName = topPrediction.key;
    final confidence = topPrediction.value;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'Reference:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Top Prediction Info - Now clickable
          InkWell(
            onTap: () {
              _navigateToMealDetail(foodName, confidence);
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '1',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      foodName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Arrow icon - clickable untuk ke detail
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white70,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _nutritionStyle() {
    return const TextStyle(color: Colors.white, fontSize: 14, height: 1.4);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.white70),
          const SizedBox(height: 16),
          const Text(
            'No predictions available',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try analyzing the image again',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 16),
          // Debug info (only in debug mode)
          if (widget.imageFile != null) ...[
            Text(
              'Image: ${widget.imageFile!.path.split('/').last}',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        // Back button
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Back',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Detail button (replaces Home button)
        Expanded(
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: widget.predictions.isNotEmpty
                ? () {
                    final topPrediction = widget.predictions.entries.first;
                    _navigateToMealDetail(
                      topPrediction.key,
                      topPrediction.value,
                    );
                  }
                : null,
            child: Text(
              'Detail',
              style: TextStyle(
                color: widget.predictions.isNotEmpty
                    ? Colors.blueAccent
                    : Colors.grey,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToMealDetail(String foodName, String confidence) {
    // Create a new MealDetailController instance with MealDbService
    final mealDbService = MealDbService();
    final mealDetailController = MealDetailController(mealDbService);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider<MealDetailController>(
          create: (_) => mealDetailController,
          child: MealDetailPage(
            foodName: foodName,
            imageFile: widget.imageFile,
            confidence: confidence,
          ),
        ),
      ),
    );
  }
}
