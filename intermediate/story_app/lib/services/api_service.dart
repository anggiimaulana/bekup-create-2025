import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:story_app/utils/constansts.dart';
import '../models/story.dart';

class ApiService {
  // Register user
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.registerEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Login user
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.loginEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['error'] == false) {
        final loginResult = LoginResult.fromJson(data['loginResult']);
        return {
          'success': true,
          'loginResult': loginResult,
          'message': data['message'],
        };
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Get all stories with pagination
  Future<Map<String, dynamic>> getStories(
    String token, {
    int page = 1,
    int size = 10,
    int location = 0,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${AppConstants.baseUrl}${AppConstants.storiesEndpoint}?page=$page&size=$size&location=$location',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && !data['error']) {
        final List<Story> stories = (data['listStory'] as List)
            .map((story) => Story.fromJson(story))
            .toList();

        // Check if there are more stories (if we got less than size, no more data)
        final hasMore = stories.length >= size;

        return {'success': true, 'stories': stories, 'hasMore': hasMore};
      } else {
        return {'success': false, 'message': data['message'], 'hasMore': false};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString(), 'hasMore': false};
    }
  }

  // Get story detail
  Future<Map<String, dynamic>> getStoryDetail(
    String token,
    String storyId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${AppConstants.baseUrl}${AppConstants.storiesEndpoint}/$storyId',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && !data['error']) {
        final story = Story.fromJson(data['story']);
        return {'success': true, 'story': story};
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Upload story with location
  Future<Map<String, dynamic>> uploadStory(
    String token,
    File imageFile,
    String description, {
    double? lat,
    double? lon,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConstants.baseUrl}${AppConstants.storiesEndpoint}'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['description'] = description;

      if (lat != null && lon != null) {
        request.fields['lat'] = lat.toString();
        request.fields['lon'] = lon.toString();
      }

      final multipartFile = await http.MultipartFile.fromPath(
        'photo',
        imageFile.path,
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['error'] == false) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}
