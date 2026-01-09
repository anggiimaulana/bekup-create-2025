import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/story.dart';
import '../screens/add_story_screen.dart';
import '../screens/login_screen.dart';
import '../screens/map_picker_screen.dart';
import '../screens/register_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/story_detail_screen.dart';
import '../screens/story_list_screen.dart';

class AppRouterDelegate extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  AppRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  bool _isAuthenticated = false;
  bool _isCheckingAuth = true;
  bool _isRegistering = false;
  bool _isAddingStory = false;
  bool _isPickingLocation = false;

  Story? _selectedStory;
  LatLng? _pickedLocation;

  bool get isAuthenticated => _isAuthenticated;
  bool get isCheckingAuth => _isCheckingAuth;

  void setAuthStatus(bool isAuthenticated) {
    _isAuthenticated = isAuthenticated;
    _isCheckingAuth = false;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _isRegistering = false;
    _isAddingStory = false;
    _isPickingLocation = false;
    _selectedStory = null;
    _pickedLocation = null;
    notifyListeners();
  }

  void goToRegister() {
    _isRegistering = true;
    notifyListeners();
  }

  void goToLogin() {
    _isRegistering = false;
    _isAddingStory = false;
    _isPickingLocation = false;
    _selectedStory = null;
    notifyListeners();
  }

  void goToHome() {
    _isAddingStory = false;
    _isPickingLocation = false;
    _selectedStory = null;
    notifyListeners();
  }

  void goToStoryDetail(Story story) {
    _selectedStory = story;
    notifyListeners();
  }

  void goToAddStory() {
    _isAddingStory = true;
    _pickedLocation = null;
    notifyListeners();
  }

  void goToMapPicker() {
    _isPickingLocation = true;
    notifyListeners();
  }

  void onLocationPicked(LatLng location) {
    _pickedLocation = location;
    _isPickingLocation = false;
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        if (_isCheckingAuth)
          const MaterialPage(
            key: ValueKey('SplashPage'),
            child: SplashScreen(),
          ),
        if (!_isCheckingAuth && !_isAuthenticated) ...[
          MaterialPage(
            key: const ValueKey('LoginPage'),
            child: LoginScreen(
              onLogin: () => setAuthStatus(true),
              onRegister: goToRegister,
            ),
          ),
          if (_isRegistering)
            MaterialPage(
              key: const ValueKey('RegisterPage'),
              child: RegisterScreen(onRegister: goToLogin, onBack: goToLogin),
            ),
        ],
        if (!_isCheckingAuth && _isAuthenticated) ...[
          MaterialPage(
            key: const ValueKey('HomePage'),
            child: StoryListScreen(
              onStoryTap: goToStoryDetail,
              onAddStory: goToAddStory,
              onLogout: logout,
            ),
          ),
          if (_isAddingStory)
            MaterialPage(
              key: const ValueKey('AddStoryPage'),
              child: AddStoryScreen(
                onStoryAdded: goToHome,
                onBack: goToHome,
                onPickLocation: goToMapPicker,
                selectedLocation: _pickedLocation,
              ),
            ),
          if (_isPickingLocation)
            MaterialPage(
              key: const ValueKey('MapPickerPage'),
              child: MapPickerScreen(
                onConfirm: onLocationPicked,
                onBack: () {
                  _isPickingLocation = false;
                  notifyListeners();
                },
              ),
            ),
          if (_selectedStory != null)
            MaterialPage(
              key: ValueKey('StoryDetailPage-${_selectedStory!.id}'),
              child: StoryDetailScreen(
                storyId: _selectedStory!.id,
                onBack: goToHome,
              ),
            ),
        ],
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) return false;

        if (_isPickingLocation) {
          _isPickingLocation = false;
        } else if (_isAddingStory) {
          _isAddingStory = false;
        } else if (_selectedStory != null) {
          _selectedStory = null;
        } else if (_isRegistering) {
          _isRegistering = false;
        }

        notifyListeners();
        return true;
      },
    );
  }

  @override
  AppRoutePath get currentConfiguration {
    if (_isCheckingAuth) return AppRoutePath.splash();
    if (!_isAuthenticated) {
      return _isRegistering ? AppRoutePath.register() : AppRoutePath.login();
    }
    if (_isAddingStory) return AppRoutePath.addStory();
    if (_selectedStory != null) {
      return AppRoutePath.storyDetail(_selectedStory!.id);
    }
    return AppRoutePath.home();
  }

  @override
  Future<void> setNewRoutePath(AppRoutePath configuration) async {
    final location = configuration.location;
    if (location == '/login') {
      _isAuthenticated = false;
      _isRegistering = false;
    } else if (location == '/register') {
      _isAuthenticated = false;
      _isRegistering = true;
    } else if (location == '/home') {
      _isAuthenticated = true;
      _isAddingStory = false;
      _selectedStory = null;
    } else if (location == '/add-story') {
      _isAuthenticated = true;
      _isAddingStory = true;
    }
    notifyListeners();
  }
}

class AppRoutePath {
  final String? location;
  final String? storyId;

  AppRoutePath.splash() : location = '/splash', storyId = null;
  AppRoutePath.login() : location = '/login', storyId = null;
  AppRoutePath.register() : location = '/register', storyId = null;
  AppRoutePath.home() : location = '/home', storyId = null;
  AppRoutePath.addStory() : location = '/add-story', storyId = null;
  AppRoutePath.storyDetail(String id) : location = '/story', storyId = id;
}
