import 'package:flutter/material.dart';
import 'package:transcript_app/model/transcript.dart';
import 'package:transcript_app/service/gemini_service.dart';
import 'package:transcript_app/utils/utils.dart';

class GeminiController extends ChangeNotifier {
  final GeminiService service;

  GeminiController(this.service);

  Transcript? _transcript;

  Transcript? get transcript => _transcript;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> generateTranscript() async {
    _transcript = null;
    _isLoading = true;
    notifyListeners();

    final file = await getFileFromAssets("softskill_podcast.mp3");
    final response = await service.generateTranscript(file);

    _transcript = Transcript.fromJson(response);
    _isLoading = false;
    notifyListeners();
  }
}
