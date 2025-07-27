import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:restaurant_app/main.dart' as app;
import 'robot/home_robot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Integration: Load HomeScreen dan tap salah satu restoran', (
    tester,
  ) async {
    final robot = HomeRobot(tester);

    app.main(); // Jalankan app
    await robot.waitForUI();

    await robot.checkAppBarVisible();
    await robot.checkRestaurantListLoaded();
    await robot.tapFirstRestaurantCard();
  });
}
