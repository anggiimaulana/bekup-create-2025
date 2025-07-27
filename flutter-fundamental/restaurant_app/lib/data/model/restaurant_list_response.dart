import 'package:restaurant_app/data/model/restaurant.dart';

class RestaurantListResponse {
  final bool error;
  final String message;
  final int count;
  final List<Restaurant> restaurants;

  RestaurantListResponse({
    required this.error,
    required this.message,
    required this.count,
    required this.restaurants,
  });

  factory RestaurantListResponse.fromJson(Map<String, dynamic> json) =>
      RestaurantListResponse(
        error: json["error"] ?? false,
        message: json["message"] ?? "",
        count: json["count"] ?? 0,
        restaurants:
            (json["restaurants"] as List<dynamic>?)
                ?.map((x) => Restaurant.fromJson(x))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
    "error": error,
    "message": message,
    "count": count,
    "restaurants": List<dynamic>.from(restaurants.map((x) => x.toJson())),
  };
}
