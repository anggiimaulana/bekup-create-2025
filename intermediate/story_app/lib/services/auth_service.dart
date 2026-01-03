import 'package:shared_preferences/shared_preferences.dart';
import 'package:story_app/utils/constansts.dart';

class AuthService {
  // Save login session
  Future<void> saveLoginSession(
    String token,
    String userId,
    String userName,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
    await prefs.setString(AppConstants.userIdKey, userId);
    await prefs.setString(AppConstants.userNameKey, userName);
    await prefs.setBool(AppConstants.isLoggedInKey, true);
  }

  // Get token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  // Get user info
  Future<Map<String, String?>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getString(AppConstants.userIdKey),
      'userName': prefs.getString(AppConstants.userNameKey),
      'token': prefs.getString(AppConstants.tokenKey),
    };
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.isLoggedInKey) ?? false;
  }

  // Logout - clear all session data
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userIdKey);
    await prefs.remove(AppConstants.userNameKey);
    await prefs.setBool(AppConstants.isLoggedInKey, false);
  }
}
