import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../model/meals_response.dart';

class MealDbService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';
  static const Duration _timeout = Duration(seconds: 10);

  // Search meals by name
  Future<List<Meal>> searchMealsByName(String query) async {
    try {
      log('Searching meals for query: $query');

      final uri = Uri.parse('$_baseUrl/search.php?s=$query');
      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final mealsResponse = MealsResponse.fromJson(data);

        final meals = mealsResponse.meals ?? [];
        log('Found ${meals.length} meals for query: $query');

        return meals;
      } else {
        log('API request failed with status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('Error searching meals: $e');
      return [];
    }
  }

  // Get meal details by ID
  Future<Meal?> getMealDetails(String mealId) async {
    try {
      log('Getting meal details for ID: $mealId');

      final uri = Uri.parse('$_baseUrl/lookup.php?i=$mealId');
      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final mealsResponse = MealsResponse.fromJson(data);

        if (mealsResponse.meals != null && mealsResponse.meals!.isNotEmpty) {
          return mealsResponse.meals!.first;
        }
      }

      return null;
    } catch (e) {
      log('Error getting meal details: $e');
      return null;
    }
  }

  // Search meals and get the most relevant one
  Future<Meal?> findMostRelevantMeal(String foodName) async {
    try {
      log('Finding most relevant meal for: $foodName');

      // First, try exact search
      List<Meal> meals = await searchMealsByName(foodName);

      if (meals.isNotEmpty) {
        // Return the first result (most relevant)
        log('Found exact match: ${meals.first.strMeal}');
        return meals.first;
      }

      // If no exact match, try searching with individual words
      final words = foodName.toLowerCase().split(' ');
      for (String word in words) {
        if (word.length > 2) {
          // Skip very short words
          meals = await searchMealsByName(word);
          if (meals.isNotEmpty) {
            log('Found match with word "$word": ${meals.first.strMeal}');
            return meals.first;
          }
        }
      }

      log('No relevant meal found for: $foodName');
      return null;
    } catch (e) {
      log('Error finding relevant meal: $e');
      return null;
    }
  }

  // Extract ingredients and measurements from meal
  List<Map<String, String>> extractIngredients(Meal meal) {
    final ingredients = <Map<String, String>>[];

    // Process all 20 possible ingredient fields
    final ingredientGetters = [
      () => meal.strIngredient1,
      () => meal.strIngredient2,
      () => meal.strIngredient3,
      () => meal.strIngredient4,
      () => meal.strIngredient5,
      () => meal.strIngredient6,
      () => meal.strIngredient7,
      () => meal.strIngredient8,
      () => meal.strIngredient9,
      () => meal.strIngredient10,
      () => meal.strIngredient11,
      () => meal.strIngredient12,
      () => meal.strIngredient13,
      () => meal.strIngredient14,
      () => meal.strIngredient15,
      () => meal.strIngredient16,
      () => meal.strIngredient17,
      () => meal.strIngredient18,
      () => meal.strIngredient19,
      () => meal.strIngredient20,
    ];

    final measureGetters = [
      () => meal.strMeasure1,
      () => meal.strMeasure2,
      () => meal.strMeasure3,
      () => meal.strMeasure4,
      () => meal.strMeasure5,
      () => meal.strMeasure6,
      () => meal.strMeasure7,
      () => meal.strMeasure8,
      () => meal.strMeasure9,
      () => meal.strMeasure10,
      () => meal.strMeasure11,
      () => meal.strMeasure12,
      () => meal.strMeasure13,
      () => meal.strMeasure14,
      () => meal.strMeasure15,
      () => meal.strMeasure16,
      () => meal.strMeasure17,
      () => meal.strMeasure18,
      () => meal.strMeasure19,
      () => meal.strMeasure20,
    ];

    for (int i = 0; i < ingredientGetters.length; i++) {
      final ingredient = ingredientGetters[i]()?.trim();
      final measure = measureGetters[i]()?.trim();

      if (ingredient != null && ingredient.isNotEmpty && ingredient != 'null') {
        ingredients.add({'ingredient': ingredient, 'measure': measure ?? ''});
      }
    }

    return ingredients;
  }

  // Format instructions into steps
  List<String> formatInstructions(String? instructions) {
    if (instructions == null || instructions.isEmpty) {
      return [];
    }

    // Split by common separators
    final steps = instructions
        .split(RegExp(r'\r?\n|\.\s+(?=[A-Z0-9])|(?<=\.)\s*\d+\.'))
        .where((step) => step.trim().isNotEmpty)
        .map((step) => step.trim())
        .toList();

    // Clean up steps
    return steps
        .map((step) {
          // Remove leading numbers and dots
          step = step.replaceFirst(RegExp(r'^\d+\.?\s*'), '');
          // Ensure step ends with period if it doesn't already
          if (!step.endsWith('.') &&
              !step.endsWith('!') &&
              !step.endsWith('?')) {
            step += '.';
          }
          return step;
        })
        .where((step) => step.length > 3)
        .toList();
  }

  // Check if service is available
  Future<bool> checkServiceAvailability() async {
    try {
      final uri = Uri.parse('$_baseUrl/search.php?s=chicken');
      final response = await http.get(uri).timeout(_timeout);
      return response.statusCode == 200;
    } catch (e) {
      log('Service availability check failed: $e');
      return false;
    }
  }
}
