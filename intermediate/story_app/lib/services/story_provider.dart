import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/story.dart';
import '../services/api_service.dart';

enum StoryState { initial, loading, loaded, error, uploading, uploaded }

class StoryProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  StoryState _state = StoryState.initial;
  List<Story> _stories = [];
  Story? _selectedStory;
  String? _errorMessage;

  StoryState get state => _state;
  List<Story> get stories => _stories;
  Story? get selectedStory => _selectedStory;
  String? get errorMessage => _errorMessage;

  // Get all stories
  Future<void> getStories(String token) async {
    _state = StoryState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _apiService.getStories(token);

    if (result['success']) {
      _stories = result['stories'];
      _state = StoryState.loaded;
    } else {
      _errorMessage = result['message'];
      _state = StoryState.error;
    }
    notifyListeners();
  }

  // Get story detail
  Future<void> getStoryDetail(String token, String storyId) async {
    _state = StoryState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _apiService.getStoryDetail(token, storyId);

    if (result['success']) {
      _selectedStory = result['story'];
      _state = StoryState.loaded;
    } else {
      _errorMessage = result['message'];
      _state = StoryState.error;
    }
    notifyListeners();
  }

  // Upload story
  Future<bool> uploadStory(
    String token,
    File imageFile,
    String description,
  ) async {
    _state = StoryState.uploading;
    _errorMessage = null;
    notifyListeners();

    final result = await _apiService.uploadStory(token, imageFile, description);

    if (result['success']) {
      _state = StoryState.uploaded;
      notifyListeners();
      // Refresh stories after upload
      await getStories(token);
      return true;
    } else {
      _errorMessage = result['message'];
      _state = StoryState.error;
      notifyListeners();
      return false;
    }
  }

  // Reset selected story
  void clearSelectedStory() {
    _selectedStory = null;
    notifyListeners();
  }
}
