import 'package:restaurant_app/data/model/restaurant_menu_category.dart';

class RestaurantMenu {
  List<RestaurantMenuCategory> foods;
  List<RestaurantMenuCategory> drinks;

  RestaurantMenu({required this.foods, required this.drinks});

  factory RestaurantMenu.fromJson(Map<String, dynamic> json) => RestaurantMenu(
    foods: List<RestaurantMenuCategory>.from(
      json["foods"].map((x) => RestaurantMenuCategory.fromJson(x)),
    ),
    drinks: List<RestaurantMenuCategory>.from(
      json["drinks"].map((x) => RestaurantMenuCategory.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "foods": List<dynamic>.from(foods.map((x) => x.toJson())),
    "drinks": List<dynamic>.from(drinks.map((x) => x.toJson())),
  };
}
