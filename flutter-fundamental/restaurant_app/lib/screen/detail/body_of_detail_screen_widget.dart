import 'package:flutter/material.dart';
import 'package:restaurant_app/data/model/restaurant_detail_response.dart';
import 'package:restaurant_app/screen/detail/customer_review_widget.dart';
import 'package:restaurant_app/screen/detail/description_restaurant.dart';
import 'package:restaurant_app/screen/detail/menu_widget.dart';
import 'package:restaurant_app/data/api/api_service.dart';

class BodyOfDetailScreenWidget extends StatelessWidget {
  final RestaurantDetail restaurantDetail;
  final apiService = ApiService();

  BodyOfDetailScreenWidget({super.key, required this.restaurantDetail});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: restaurantDetail.pictureId,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  restaurantDetail.largeImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildHeader(context),
            const SizedBox(height: 16),
            DescriptionRestaurant(restaurantDetail: restaurantDetail),
            const SizedBox(height: 16),
            MenuWidget(restaurantDetail: restaurantDetail),
            const SizedBox(height: 16),
            CustomerReviewWidget(restaurantDetail: restaurantDetail),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                restaurantDetail.name,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              Row(
                children: [
                  const Icon(Icons.pin_drop, color: Colors.redAccent),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      "${restaurantDetail.address}, ${restaurantDetail.city}",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
