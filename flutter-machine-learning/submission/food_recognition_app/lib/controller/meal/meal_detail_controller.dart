import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:food_recognition_app/service/meal_db_service.dart';
import '../../model/meals_response.dart';

class MealDetailController extends ChangeNotifier {
  final MealDbService _mealDbService;

  // State variables
  bool _isLoading = false;
  Meal? _mealDetail;
  String? _errorMessage;
  List<Map<String, String>> _ingredients = [];
  List<String> _instructions = [];

  // Constructor
  MealDetailController(this._mealDbService);

  // Getters
  bool get isLoading => _isLoading;
  Meal? get mealDetail => _mealDetail;
  String? get errorMessage => _errorMessage;
  List<Map<String, String>> get ingredients => _ingredients;
  List<String> get instructions => _instructions;

  // Check if we have meal data
  bool get hasMealData => _mealDetail != null;

  // Load meal details by food name (from prediction)
  Future<void> loadMealByFoodName(String foodName) async {
    try {
      _setLoading(true);
      _clearError();
      _clearData();

      log('Loading meal details for food name: $foodName');

      // Find the most relevant meal
      final meal = await _mealDbService.findMostRelevantMeal(foodName);

      if (meal != null) {
        _mealDetail = meal;
        _processMealData(meal);

        log('Successfully loaded meal: ${meal.strMeal}');
      } else {
        _setError('No recipe found for "$foodName"');
        log('No meal found for food name: $foodName');
      }
    } catch (e) {
      final errorMsg = 'Failed to load meal details: $e';
      _setError(errorMsg);
      log('Error loading meal by food name: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load meal details by meal ID
  Future<void> loadMealById(String mealId) async {
    try {
      _setLoading(true);
      _clearError();
      _clearData();

      log('Loading meal details for ID: $mealId');

      final meal = await _mealDbService.getMealDetails(mealId);

      if (meal != null) {
        _mealDetail = meal;
        _processMealData(meal);

        log('Successfully loaded meal by ID: ${meal.strMeal}');
      } else {
        _setError('Meal not found');
        log('No meal found for ID: $mealId');
      }
    } catch (e) {
      final errorMsg = 'Failed to load meal details: $e';
      _setError(errorMsg);
      log('Error loading meal by ID: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Process meal data to extract ingredients and instructions
  void _processMealData(Meal meal) {
    try {
      // Extract ingredients and measurements
      _ingredients = _mealDbService.extractIngredients(meal);
      log('Extracted ${_ingredients.length} ingredients');

      // Format instructions into steps
      _instructions = _mealDbService.formatInstructions(meal.strInstructions);
      log('Formatted ${_instructions.length} instruction steps');
    } catch (e) {
      log('Error processing meal data: $e');
    }
  }

  // Search for alternative meals by name
  Future<List<Meal>> searchAlternativeMeals(String query) async {
    try {
      log('Searching alternative meals for: $query');

      final meals = await _mealDbService.searchMealsByName(query);

      // Exclude current meal if loaded
      if (_mealDetail != null) {
        meals.removeWhere((meal) => meal.idMeal == _mealDetail!.idMeal);
      }

      log('Found ${meals.length} alternative meals');
      return meals.take(5).toList(); // Return top 5 alternatives
    } catch (e) {
      log('Error searching alternative meals: $e');
      return [];
    }
  }

  // Get formatted cooking time (if available in tags or instructions)
  String getCookingTime() {
    if (_mealDetail?.strTags != null) {
      final tags = _mealDetail!.strTags!.toLowerCase();

      // Look for time indicators in tags
      final timePattern = RegExp(r'(\d+)\s*(min|hour|hr)');
      final match = timePattern.firstMatch(tags);

      if (match != null) {
        return '${match.group(1)} ${match.group(2)}';
      }
    }

    return 'Not specified';
  }

  // Get meal category with proper formatting
  String getFormattedCategory() {
    return _mealDetail?.strCategory ?? 'Unknown';
  }

  // Get meal area/cuisine with proper formatting
  String getFormattedArea() {
    return _mealDetail?.strArea ?? 'Unknown';
  }

  // Get formatted tags
  List<String> getFormattedTags() {
    if (_mealDetail?.strTags == null || _mealDetail!.strTags!.isEmpty) {
      return [];
    }

    return _mealDetail!.strTags!
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  // Check if meal has video tutorial
  bool hasVideoTutorial() {
    return _mealDetail?.strYoutube != null &&
        _mealDetail!.strYoutube!.isNotEmpty;
  }

  // Get YouTube video ID from URL
  String? getYouTubeVideoId() {
    if (!hasVideoTutorial()) return null;

    final url = _mealDetail!.strYoutube!;
    final regex = RegExp(r'(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\n?#]+)');
    final match = regex.firstMatch(url);

    return match?.group(1);
  }

  // Get ingredient count
  int getIngredientCount() {
    return _ingredients.length;
  }

  // Get instruction step count
  int getInstructionStepCount() {
    return _instructions.length;
  }

  // Get meal summary info
  Map<String, dynamic> getMealSummary() {
    if (_mealDetail == null) return {};

    return {
      'name': _mealDetail!.strMeal ?? 'Unknown',
      'category': getFormattedCategory(),
      'area': getFormattedArea(),
      'ingredientCount': getIngredientCount(),
      'stepCount': getInstructionStepCount(),
      'hasVideo': hasVideoTutorial(),
      'tags': getFormattedTags(),
    };
  }

  // Retry loading current meal
  Future<void> retry() async {
    if (_mealDetail != null && _mealDetail!.idMeal != null) {
      await loadMealById(_mealDetail!.idMeal!);
    }
  }

  // Clear all data
  void _clearData() {
    _mealDetail = null;
    _ingredients.clear();
    _instructions.clear();
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

  // Reset controller
  void reset() {
    _isLoading = false;
    _clearError();
    _clearData();
    notifyListeners();
  }

  // Controller status
  Map<String, dynamic> get status => {
    'isLoading': _isLoading,
    'hasError': _errorMessage != null,
    'errorMessage': _errorMessage,
    'hasMealData': hasMealData,
    'ingredientCount': getIngredientCount(),
    'instructionCount': getInstructionStepCount(),
  };

  @override
  void dispose() {
    _clearData();
    super.dispose();
  }
}
