import 'package:flutter/material.dart';
import '../models/story.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/story_list_screen.dart';
import '../screens/story_detail_screen.dart';
import '../screens/add_story_screen.dart';
import '../screens/splash_screen.dart';

class AppRouterDelegate extends RouterDelegate<AppRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  bool _isAuthenticated = false;
  bool _isCheckingAuth = true;
  bool _isRegistering = false;
  bool _isAddingStory = false;
  Story? _selectedStory;

  AppRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  bool get isAuthenticated => _isAuthenticated;
  bool get isCheckingAuth => _isCheckingAuth;

  // Set authentication status
  void setAuthStatus(bool isAuthenticated) {
    _isAuthenticated = isAuthenticated;
    _isCheckingAuth = false;
    notifyListeners();
  }

  // Navigate to register
  void goToRegister() {
    _isRegistering = true;
    notifyListeners();
  }

  // Navigate to login
  void goToLogin() {
    _isRegistering = false;
    _isAddingStory = false;
    _selectedStory = null;
    notifyListeners();
  }

  // Navigate to story list (home)
  void goToHome() {
    _isAddingStory = false;
    _selectedStory = null;
    notifyListeners();
  }

  // Navigate to story detail
  void goToStoryDetail(Story story) {
    _selectedStory = story;
    notifyListeners();
  }

  // Navigate to add story
  void goToAddStory() {
    _isAddingStory = true;
    notifyListeners();
  }

  // Handle logout
  void logout() {
    _isAuthenticated = false;
    _isRegistering = false;
    _isAddingStory = false;
    _selectedStory = null;
    notifyListeners();
  }

  @override
  AppRoutePath get currentConfiguration {
    if (_isCheckingAuth) {
      return AppRoutePath.splash();
    }
    if (!_isAuthenticated) {
      if (_isRegistering) {
        return AppRoutePath.register();
      }
      return AppRoutePath.login();
    }
    if (_isAddingStory) {
      return AppRoutePath.addStory();
    }
    if (_selectedStory != null) {
      return AppRoutePath.storyDetail(_selectedStory!.id);
    }
    return AppRoutePath.home();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        // Splash screen while checking auth
        if (_isCheckingAuth)
          const MaterialPage(
            key: ValueKey('SplashPage'),
            child: SplashScreen(),
          ),

        // Authentication pages
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

        // Main app pages
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
              child: AddStoryScreen(onStoryAdded: goToHome, onBack: goToHome),
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
        if (!route.didPop(result)) {
          return false;
        }

        // Handle back navigation
        if (_selectedStory != null) {
          _selectedStory = null;
          notifyListeners();
        } else if (_isAddingStory) {
          _isAddingStory = false;
          notifyListeners();
        } else if (_isRegistering) {
          _isRegistering = false;
          notifyListeners();
        }

        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(AppRoutePath configuration) async {
    if (configuration.location == '/login') {
      _isRegistering = false;
      _isAuthenticated = false;
    } else if (configuration.location == '/register') {
      _isRegistering = true;
      _isAuthenticated = false;
    } else if (configuration.location == '/home') {
      _isAuthenticated = true;
      _isAddingStory = false;
      _selectedStory = null;
    } else if (configuration.location == '/add-story') {
      _isAuthenticated = true;
      _isAddingStory = true;
    } else if (configuration.location == '/story' &&
        configuration.storyId != null) {
      _isAuthenticated = true;
    }
    notifyListeners();
  }
}

// Route path configuration
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
