import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/data/model/restaurant/restaurant.dart';
import 'package:restaurant_app/provider/home/restaurant_list_provider.dart';
import 'package:restaurant_app/static/restaurant_list_result_state.dart';
import '../mock_api_service.mocks.dart';

void main() {
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
  });

  Widget createWidgetUnderTest(RestaurantListResultState state) {
    final provider = RestaurantListProvider(mockApiService);
    provider.setResultStateForTest(state);

    return ChangeNotifierProvider<RestaurantListProvider>.value(
      value: provider,
      child: const MaterialApp(home: HomeScreenFake()),
    );
  }

  testWidgets('Menampilkan loading saat state adalah loading', (tester) async {
    await tester.pumpWidget(
      createWidgetUnderTest(RestaurantListLoadingState()),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Menampilkan error message saat state error', (tester) async {
    const errorMessage = 'Gagal mengambil data';
    await tester.pumpWidget(
      createWidgetUnderTest(RestaurantListErrorState(errorMessage)),
    );
    await tester.pump();

    expect(find.text(errorMessage), findsOneWidget);
  });

  testWidgets('Menampilkan daftar restoran saat fetch sukses', (tester) async {
    final fakeRestaurant = [
      FakeRestaurant(
        id: 'w9pga3s2tubkfw1e867',
        name: 'Bring Your Phone Cafe',
        city: 'Surabaya',
        rating: 4.2,
        pictureId: '03',
        description: 'Deskripsi',
      ),
    ];

    await tester.pumpWidget(
      createWidgetUnderTest(RestaurantListLoadedState(fakeRestaurant)),
    );
    await tester.pump();

    expect(find.text('Bring Your Phone Cafe'), findsOneWidget);
    expect(find.text('Surabaya'), findsOneWidget);
    expect(find.text('4.2'), findsOneWidget);
  });
}

/// Dummy HomeScreen tanpa call fetchRestaurantList()
class HomeScreenFake extends StatelessWidget {
  const HomeScreenFake({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fake Home")),
      body: Consumer<RestaurantListProvider>(
        builder: (context, value, child) {
          return switch (value.resultState) {
            RestaurantListLoadingState() => const Center(
              child: CircularProgressIndicator(),
            ),
            RestaurantListLoadedState(data: var restaurants) => ListView(
              children: restaurants.map((r) {
                return ListTile(
                  title: Text(r.name),
                  subtitle: Text(r.city),
                  trailing: Text(r.rating.toString()),
                );
              }).toList(),
            ),
            RestaurantListErrorState(error: var message) => Center(
              child: Text(message),
            ),
            _ => const SizedBox(),
          };
        },
      ),
    );
  }
}

/// Dummy class yang extend Restaurant
class FakeRestaurant extends Restaurant {
  FakeRestaurant({
    required super.id,
    required super.name,
    required super.description,
    required super.pictureId,
    required super.city,
    required super.rating,
  });
}
