import 'package:flutter/material.dart';

class AppConstants {
  // API Configuration
  static const String baseUrl = 'https://story-api.dicoding.dev/v1';
  static const String registerEndpoint = '/register';
  static const String loginEndpoint = '/login';
  static const String storiesEndpoint = '/stories';

  // SharedPreferences Keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userNameKey = 'user_name';
  static const String isLoggedInKey = 'is_logged_in';

  // Colors
  static const Color primaryColor = Color(0xFF347DC6);
  static const Color backgroundColor = Color(0xFFF6F8FD);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFE74C3C);
  static const Color successColor = Color(0xFF27AE60);
  static const Color textPrimaryColor = Color(0xFF2C3E50);
  static const Color textSecondaryColor = Color(0xFF7F8C8D);

  // Sizes
  static const double defaultPadding = 16.0;
  static const double borderRadius = 12.0;
  static const double buttonHeight = 48.0;
}
