import 'package:flutter/material.dart';
import 'package:restaurant_app/data/api/api_service.dart';
import 'package:restaurant_app/static/restaurant_detail_result_state.dart';

class RestaurantDetailProvider extends ChangeNotifier {
  final ApiService _apiService;

  RestaurantDetailProvider(this._apiService);

  RestaurantDetailResultState _resultState = RestaurantDetailNoneState();
  RestaurantDetailResultState get resultState => _resultState;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  void setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }

  Future<void> fetchRestaurantDetail(String id) async {
    try {
      _resultState = RestaurantDetailLoadingState();
      notifyListeners();

      final result = await _apiService.getRestaurantDetail(id);

      if (result.error) {
        _resultState = RestaurantDetailErrorState(result.message);
      } else {
        _resultState = RestaurantDetailLoadedState(result.restaurant);
      }

      notifyListeners();
    } on Exception catch (e) {
      _resultState = RestaurantDetailErrorState(e.toString());
      notifyListeners();
    }
  }

  Future<void> addReview(
    String restaurantId,
    String reviewerName,
    String reviewText,
  ) async {
    try {
      await _apiService.addCustomerReview(
        restaurantId,
        reviewerName,
        reviewText,
      );

      try {
        await fetchRestaurantDetail(restaurantId);
      } catch (e) {
        debugPrint("Review berhasil, tapi gagal refresh data: $e");
      }
    } catch (e) {
      debugPrint("Gagal kirim review: $e");
      throw Exception("Gagal mengirim review");
    }
  }
}
