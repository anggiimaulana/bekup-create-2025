import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:restaurant_app/data/model/restaurant/restaurant.dart';
import 'package:restaurant_app/data/model/restaurant/restaurant_list_response.dart';
import 'package:restaurant_app/provider/home/restaurant_list_provider.dart';
import 'package:restaurant_app/static/restaurant_list_result_state.dart';
import '../mock_api_service.mocks.dart'; // auto-generated

void main() {
  late MockApiService mockApiService;
  late RestaurantListProvider provider;

  setUp(() {
    mockApiService = MockApiService();
    provider = RestaurantListProvider(mockApiService);
  });

  test('1. State awal provider harus didefinisikan', () {
    expect(provider.resultState, isA<RestaurantListNoneState>());
  });

  test('2. Mengembalikan daftar restoran saat fetch berhasil', () async {
    final mockRestaurants = [
      Restaurant(
        id: 'rqdv5juczeskfw1e867',
        name: 'Melting Pot',
        description: 'Deskripsi...',
        pictureId: '14',
        city: 'Medan',
        rating: 4.2,
      ),
    ];

    final response = RestaurantListResponse(
      error: false,
      message: 'success',
      count: 1,
      restaurants: mockRestaurants,
    );

    when(mockApiService.getRestaurantList()).thenAnswer((_) async => response);

    await provider.fetchRestaurantList();

    expect(provider.resultState, isA<RestaurantListLoadedState>());
    final state = provider.resultState as RestaurantListLoadedState;
    expect(state.data.length, 1);
    expect(state.data.first.name, 'Melting Pot');
  });

  test('3. Mengembalikan kesalahan saat fetch gagal', () async {
    when(
      mockApiService.getRestaurantList(),
    ).thenThrow(Exception('No internet'));

    await provider.fetchRestaurantList();

    expect(provider.resultState, isA<RestaurantListErrorState>());
    final state = provider.resultState as RestaurantListErrorState;
    expect(state.error, contains('No internet'));
  });
}
