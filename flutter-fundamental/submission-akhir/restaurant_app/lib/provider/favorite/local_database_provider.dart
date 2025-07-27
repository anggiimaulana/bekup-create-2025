import 'package:flutter/material.dart';
import 'package:restaurant_app/data/local/local_database_service.dart';
import 'package:restaurant_app/data/model/restaurant/restaurant.dart';

class LocalDatabaseProvider extends ChangeNotifier {
  final LocalDatabaseService _service;

  LocalDatabaseProvider(this._service);

  String _message = "";
  String get message => _message;

  List<Restaurant>? _restaurantList;
  List<Restaurant>? get restaurantList => _restaurantList;

  Restaurant? _restaurant;
  Restaurant? get restaurant => _restaurant;

  Future<void> saveRestaurant(Restaurant value) async {
    try {
      final result = await _service.insertItem(value);
      _message = result == 0
          ? "Failed to save your data"
          : "Your data has been saved";
    } catch (e) {
      _message = "Failed to save your data: $e";
    }
    notifyListeners();
  }

  Future<void> loadAllRestaurant() async {
    try {
      _restaurantList = await _service.getAllItems();
      _restaurant = null;
      _message = "All of your data is loaded";
    } catch (e) {
      _message = "Failed to load your data: $e";
    }
    notifyListeners();
  }

  Future<void> loadRestaurantById(String id) async {
    try {
      _restaurant = await _service.getItemById(id);
      _message = "Your data is loaded";
    } catch (e) {
      _message = "Failed to load your data: $e";
    }
    notifyListeners();
  }

  Future<void> removeRestaurantById(String id) async {
    try {
      await _service.removeItem(id);
      _message = "Your data has been removed";

      await loadAllRestaurant();
    } catch (e) {
      _message = "Failed to remove your data: $e";
      notifyListeners();
    }
  }

  bool checkItemBookmark(String id) {
    return _restaurant?.id == id;
  }

  Future<bool> isRestaurantBookmarked(String id) async {
    try {
      await _service.getItemById(id);
      return true;
    } catch (_) {
      return false;
    }
  }
}
