import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/data/model/restaurant/restaurant.dart';
import 'package:restaurant_app/provider/favorite/local_database_provider.dart';
import 'package:restaurant_app/provider/detail/favorite_icon_provider.dart';

class FavoriteIconWidget extends StatefulWidget {
  final Restaurant restaurant;
  const FavoriteIconWidget({super.key, required this.restaurant});

  @override
  State<FavoriteIconWidget> createState() => _FavoriteIconWidgetState();
}

class _FavoriteIconWidgetState extends State<FavoriteIconWidget> {
  @override
  void initState() {
    super.initState();
    final localDatabaseProvider = context.read<LocalDatabaseProvider>();
    final favoriteIconProvider = context.read<FavoriteIconProvider>();

    Future.microtask(() async {
      await localDatabaseProvider.loadRestaurantById(widget.restaurant.id);

      if (localDatabaseProvider.restaurant != null) {
        final value = localDatabaseProvider.checkItemBookmark(
          widget.restaurant.id,
        );
        favoriteIconProvider.isFavorite = value;
      } else {
        favoriteIconProvider.isFavorite = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localDatabaseProvider = context.read<LocalDatabaseProvider>();
    final favoriteIconProvider = context.watch<FavoriteIconProvider>();

    return IconButton(
      onPressed: () async {
        final isFavorite = favoriteIconProvider.isFavorite;

        if (!isFavorite) {
          await localDatabaseProvider.saveRestaurant(widget.restaurant);
        } else {
          await localDatabaseProvider.removeRestaurantById(
            widget.restaurant.id,
          );
        }

        favoriteIconProvider.isFavorite = !isFavorite;
        await localDatabaseProvider.loadAllRestaurant();
      },
      icon: Icon(
        favoriteIconProvider.isFavorite
            ? Icons.favorite
            : Icons.favorite_border,
        color: favoriteIconProvider.isFavorite ? Colors.redAccent : null,
      ),
    );
  }
}
