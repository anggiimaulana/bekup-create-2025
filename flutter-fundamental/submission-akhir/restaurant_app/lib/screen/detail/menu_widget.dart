import 'package:flutter/material.dart';
import 'package:restaurant_app/data/model/restaurant/restaurant_detail_response.dart';

class MenuWidget extends StatelessWidget {
  final RestaurantDetail restaurantDetail;
  const MenuWidget({super.key, required this.restaurantDetail});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Menu", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Foods", style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...restaurantDetail.menus.foods.map(
                    (food) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(food.name),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Drinks",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ...restaurantDetail.menus.drinks.map(
                    (drink) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(drink.name),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
