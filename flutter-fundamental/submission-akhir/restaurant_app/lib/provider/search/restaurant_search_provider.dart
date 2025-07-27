import 'package:flutter/material.dart';
import 'package:restaurant_app/data/api/api_service.dart';
import 'package:restaurant_app/data/model/restaurant/restaurant.dart';

enum ResultState { loading, noData, hasData, error }

class RestaurantSearchProvider extends ChangeNotifier {
  final ApiService apiService;

  RestaurantSearchProvider({required this.apiService});

  ResultState _state = ResultState.noData;
  ResultState get state => _state;

  List<Restaurant> _restaurants = [];
  List<Restaurant> get restaurants => _restaurants;

  String _message = '';
  String get message => _message;

  Future<void> searchRestaurant(String query) async {
    try {
      _state = ResultState.loading;
      notifyListeners();

      final result = await apiService.getRestaurantSearch(query);
      if (result.restaurants.isEmpty) {
        _state = ResultState.noData;
        _message = 'No restaurants found';
      } else {
        _state = ResultState.hasData;
        _restaurants = result.restaurants;
      }
      notifyListeners();
    } catch (e) {
      _state = ResultState.error;
      _message = 'Error: $e';
      notifyListeners();
    }
  }
}
