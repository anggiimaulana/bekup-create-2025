import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/data/api/api_service.dart';
import 'package:restaurant_app/data/local/local_database_service.dart';
import 'package:restaurant_app/provider/detail/restaurant_detail_provider.dart';
import 'package:restaurant_app/provider/favorite/local_database_provider.dart';
import 'package:restaurant_app/provider/home/restaurant_list_provider.dart';
import 'package:restaurant_app/provider/index_nav_provider.dart';
import 'package:restaurant_app/provider/local/local_notification_provider.dart';
import 'package:restaurant_app/provider/local/shared_preferences_provider.dart';
import 'package:restaurant_app/provider/search/restaurant_search_provider.dart';
import 'package:restaurant_app/provider/setting/daily_reminder_state_provider.dart';
import 'package:restaurant_app/provider/setting/theme_state_provider.dart';
import 'package:restaurant_app/screen/detail/detail_screen.dart';
import 'package:restaurant_app/screen/main/main_screen.dart';
import 'package:restaurant_app/service/http_service.dart';
import 'package:restaurant_app/service/local_notification_services.dart';
import 'package:restaurant_app/service/shared_preferences_service.dart';
import 'package:restaurant_app/static/navigation_route.dart';
import 'package:restaurant_app/style/theme/restaurant_theme.dart';
import 'package:restaurant_app/utils/theme_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => HttpService()),

        ProxyProvider<HttpService, LocalNotificationService>(
          update: (_, httpService, __) {
            final service = LocalNotificationService(httpService);
            service.init();
            service.configureLocalTimeZone();
            return service;
          },
        ),

        Provider(create: (_) => SharedPreferencesService(prefs)),

        ChangeNotifierProvider(
          create: (context) => SharedPreferencesProvider(
            context.read<SharedPreferencesService>(),
          ),
        ),

        ChangeNotifierProvider(create: (_) => IndexNavProvider()),
        Provider(create: (_) => ApiService()),
        Provider(create: (_) => LocalDatabaseService()),

        ChangeNotifierProvider(
          create: (context) =>
              LocalDatabaseProvider(context.read<LocalDatabaseService>()),
        ),

        ChangeNotifierProvider(
          create: (context) =>
              RestaurantListProvider(context.read<ApiService>()),
        ),

        ChangeNotifierProvider(
          create: (_) => RestaurantSearchProvider(apiService: ApiService()),
        ),

        ChangeNotifierProvider(
          create: (context) =>
              RestaurantDetailProvider(context.read<ApiService>()),
        ),

        ChangeNotifierProvider(
          create: (context) =>
              ThemeStateProvider(context.read<SharedPreferencesService>()),
        ),

        ChangeNotifierProxyProvider<
          LocalNotificationService,
          LocalNotificationProvider
        >(
          create: (_) => LocalNotificationProvider(
            LocalNotificationService(HttpService()),
          ),
          update: (_, localNotificationService, __) =>
              LocalNotificationProvider(localNotificationService),
        ),
        ChangeNotifierProvider(create: (_) => DailyReminderStateProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeStateProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Restaurant App',
          theme: RestaurantTheme.lightTheme,
          darkTheme: RestaurantTheme.darkTheme,
          themeMode: themeProvider.notificationState == ThemeState.lightTheme
              ? ThemeMode.light
              : ThemeMode.dark,
          initialRoute: NavigationRoute.mainRoute.name,
          routes: {
            NavigationRoute.mainRoute.name: (context) => const MainScreen(),
            NavigationRoute.detailRoute.name: (context) {
              final args = ModalRoute.of(context)?.settings.arguments;
              if (args is String) {
                return DetailScreen(restaurantId: args);
              } else {
                return const Scaffold(
                  body: Center(
                    child: Text("Error: No restaurant ID provided."),
                  ),
                );
              }
            },
          },
        );
      },
    );
  }
}
