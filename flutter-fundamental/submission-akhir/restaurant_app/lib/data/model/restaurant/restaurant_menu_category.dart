class RestaurantMenuCategory {
  String name;

  RestaurantMenuCategory({required this.name});

  factory RestaurantMenuCategory.fromJson(Map<String, dynamic> json) =>
      RestaurantMenuCategory(name: json["name"]);

  Map<String, dynamic> toJson() => {"name": name};
}
