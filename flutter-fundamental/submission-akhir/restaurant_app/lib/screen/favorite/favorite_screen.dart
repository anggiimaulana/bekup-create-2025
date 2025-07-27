import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/provider/favorite/local_database_provider.dart';
import 'package:restaurant_app/screen/home/restaurant_card_widget.dart';
import 'package:restaurant_app/static/navigation_route.dart';
import 'package:restaurant_app/style/colors/restaurant_color.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!_isLoaded) {
        context.read<LocalDatabaseProvider>().loadAllRestaurant();
        _isLoaded = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Text(
          "Favorite List",
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(color: Colors.white),
        ),
        backgroundColor: RestaurantColor.blue.color,
      ),
      body: Consumer<LocalDatabaseProvider>(
        builder: (context, provider, child) {
          final bookmarkList = provider.restaurantList ?? [];

          if (bookmarkList.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text("No Favorite Restaurant")],
              ),
            );
          }

          return ListView.builder(
            itemCount: bookmarkList.length,
            itemBuilder: (context, index) {
              final restaurant = bookmarkList[index];
              return RestaurantCardWidget(
                restaurant: restaurant,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    NavigationRoute.detailRoute.name,
                    arguments: restaurant.id,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
