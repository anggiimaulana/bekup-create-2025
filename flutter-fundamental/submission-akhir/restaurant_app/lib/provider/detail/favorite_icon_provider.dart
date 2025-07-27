import 'package:flutter/material.dart';
import 'package:restaurant_app/data/model/restaurant/restaurant.dart';
import 'package:restaurant_app/data/local/local_database_service.dart';
import 'package:restaurant_app/provider/favorite/local_database_provider.dart';

class FavoriteIconProvider extends ChangeNotifier {
  final LocalDatabaseProvider _dbProvider = LocalDatabaseProvider(
    LocalDatabaseService(),
  );

  bool _isFavorite = false;
  bool get isFavorite => _isFavorite;

  set isFavorite(bool value) {
    _isFavorite = value;
    notifyListeners();
  }

  Future<void> loadRestaurantById(String id) async {
    final exist = await _dbProvider.isRestaurantBookmarked(id);
    _isFavorite = exist;
    notifyListeners();
  }

  Future<void> toggleFavorite(Restaurant restaurant) async {
    if (_isFavorite) {
      await _dbProvider.removeRestaurantById(restaurant.id);
    } else {
      await _dbProvider.saveRestaurant(restaurant);
    }
    _isFavorite = !_isFavorite;
    notifyListeners();
  }
}
