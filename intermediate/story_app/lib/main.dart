import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story_app/l10n/app_localizations.dart';
import 'package:story_app/routes/route_delegate.dart';
import 'package:story_app/services/story_provider.dart';
import 'package:story_app/utils/constansts.dart';
import 'providers/auth_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppRouterDelegate _routerDelegate;
  late AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _routerDelegate = AppRouterDelegate();
    _authProvider = AuthProvider();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await _authProvider.checkAuthStatus();
    _routerDelegate.setAuthStatus(_authProvider.isAuthenticated);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider(create: (_) => StoryProvider()),
        ChangeNotifierProvider.value(value: _routerDelegate),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          // Update router when auth state changes
          if (!_routerDelegate.isCheckingAuth) {
            _routerDelegate.setAuthStatus(authProvider.isAuthenticated);
          }

          return MaterialApp.router(
            title: 'Story App',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primaryColor: AppConstants.primaryColor,
              scaffoldBackgroundColor: AppConstants.backgroundColor,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppConstants.primaryColor,
                primary: AppConstants.primaryColor,
                secondary: AppConstants.primaryColor,
              ),
              useMaterial3: true,
            ),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('id')],
            routerDelegate: _routerDelegate,
            routeInformationParser: AppRouteInformationParser(),
            backButtonDispatcher: RootBackButtonDispatcher(),
          );
        },
      ),
    );
  }
}

// Route information parser for declarative navigation
class AppRouteInformationParser extends RouteInformationParser<AppRoutePath> {
  @override
  Future<AppRoutePath> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final uri = Uri.parse(routeInformation.location ?? '/');

    if (uri.pathSegments.isEmpty) {
      return AppRoutePath.splash();
    }

    if (uri.pathSegments.length == 1) {
      final path = uri.pathSegments[0];
      if (path == 'login') return AppRoutePath.login();
      if (path == 'register') return AppRoutePath.register();
      if (path == 'home') return AppRoutePath.home();
      if (path == 'add-story') return AppRoutePath.addStory();
    }

    if (uri.pathSegments.length == 2) {
      if (uri.pathSegments[0] == 'story') {
        final id = uri.pathSegments[1];
        return AppRoutePath.storyDetail(id);
      }
    }

    return AppRoutePath.splash();
  }

  @override
  RouteInformation? restoreRouteInformation(AppRoutePath configuration) {
    return RouteInformation(location: configuration.location);
  }
}
