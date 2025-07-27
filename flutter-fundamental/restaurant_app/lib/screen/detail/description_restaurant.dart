import 'package:flutter/material.dart';
import 'package:restaurant_app/data/model/restaurant_detail_response.dart';

class DescriptionRestaurant extends StatelessWidget {
  final RestaurantDetail restaurantDetail;
  const DescriptionRestaurant({super.key, required this.restaurantDetail});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Description", style: Theme.of(context).textTheme.titleLarge),
        Text(
          restaurantDetail.description,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}
