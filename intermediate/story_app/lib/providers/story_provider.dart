import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/story.dart';
import '../services/api_service.dart';

enum StoryState {
  initial,
  loading,
  loaded,
  error,
  uploading,
  uploaded,
  loadingMore,
}

class StoryProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  StoryState _state = StoryState.initial;
  List<Story> _stories = [];
  Story? _selectedStory;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;

  StoryState get state => _state;
  List<Story> get stories => _stories;
  Story? get selectedStory => _selectedStory;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  // Get stories with pagination
  Future<void> getStories(String token, {bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _stories.clear();
      _hasMore = true;
    }

    if (!_hasMore) return;

    _state = _currentPage == 1 ? StoryState.loading : StoryState.loadingMore;
    _errorMessage = null;
    notifyListeners();

    final result = await _apiService.getStories(
      token,
      page: _currentPage,
      size: 10,
    );

    if (result['success']) {
      final List<Story> newStories = result['stories'];
      _stories.addAll(newStories);
      _hasMore = result['hasMore'] ?? false;
      _currentPage++;
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

  // Upload story with location
  Future<bool> uploadStory(
    String token,
    File imageFile,
    String description, {
    double? lat,
    double? lon,
  }) async {
    _state = StoryState.uploading;
    _errorMessage = null;
    notifyListeners();

    final result = await _apiService.uploadStory(
      token,
      imageFile,
      description,
      lat: lat,
      lon: lon,
    );

    if (result['success']) {
      _state = StoryState.uploaded;
      notifyListeners();
      // Refresh stories after upload
      await getStories(token, refresh: true);
      return true;
    } else {
      _errorMessage = result['message'];
      _state = StoryState.error;
      notifyListeners();
      return false;
    }
  }

  void clearSelectedStory() {
    _selectedStory = null;
    notifyListeners();
  }
}
