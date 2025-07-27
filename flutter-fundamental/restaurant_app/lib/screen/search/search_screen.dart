import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/provider/search/restaurant_search_provider.dart';
import 'package:restaurant_app/screen/home/restaurant_card_widget.dart';
import 'package:restaurant_app/style/colors/restaurant_color.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  void _onSearch(String query) {
    if (query.isNotEmpty) {
      Provider.of<RestaurantSearchProvider>(
        context,
        listen: false,
      ).searchRestaurant(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Text(
          "Search Restaurants",
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(color: Colors.white),
        ),
        backgroundColor: RestaurantColor.blue.color,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 16, right: 16),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Search...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _onSearch(_controller.text),
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: _onSearch,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Consumer<RestaurantSearchProvider>(
              builder: (context, provider, child) {
                switch (provider.state) {
                  case ResultState.loading:
                    return const Center(child: CircularProgressIndicator());
                  case ResultState.hasData:
                    return ListView.builder(
                      itemCount: provider.restaurants.length,
                      itemBuilder: (context, index) {
                        final restaurant = provider.restaurants[index];
                        return RestaurantCardWidget(
                          restaurant: restaurant,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/detail-route',
                              arguments: restaurant.id,
                            );
                          },
                        );
                      },
                    );
                  case ResultState.noData:
                  case ResultState.error:
                    return Center(child: Text(provider.message));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
