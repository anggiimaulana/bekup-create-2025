import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class HomeRobot {
  final WidgetTester tester;

  const HomeRobot(this.tester);

  final appBarTitleText = 'Restaurants';
  final restaurantCardType =
      GestureDetector; // RestaurantCardWidget wrapped in GestureDetector

  Future<void> waitForUI() async {
    await tester.pumpAndSettle(const Duration(seconds: 5));
  }

  Future<void> checkAppBarVisible() async {
    expect(find.text(appBarTitleText), findsOneWidget);
  }

  Future<void> checkRestaurantListLoaded() async {
    expect(find.byType(restaurantCardType), findsWidgets);
  }

  Future<void> tapFirstRestaurantCard() async {
    final firstCard = find.byType(restaurantCardType).first;
    await tester.tap(firstCard);
    await tester.pumpAndSettle();
  }
}
