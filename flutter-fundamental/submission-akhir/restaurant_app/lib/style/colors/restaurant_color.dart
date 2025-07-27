import 'package:flutter/material.dart';

enum RestaurantColor {
  blue("Blue", Colors.blue);

  const RestaurantColor(this.name, this.color);

  final String name;
  final Color color;
}
