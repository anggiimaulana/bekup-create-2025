import 'package:entity_extraction_app/service/entity_extraction_service.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';

class MessageProvider extends ChangeNotifier {
  final EntityExtractionService _service;

  MessageProvider(this._service);

  bool _isExtracting = false;
  bool get isExtracting => _isExtracting;

  List<EntityAnnotation> _listOfEntityAnnotation = [];
  List<EntityAnnotation> get listOfEntityAnnotation => _listOfEntityAnnotation;

  void extractText(String text) async {
    if (text.trim().isEmpty) return;

    _isExtracting = true;
    _listOfEntityAnnotation = [];
    notifyListeners();

    try {
      _listOfEntityAnnotation = await _service.extractEntity(text);
      print("${_listOfEntityAnnotation.length}");
    } catch (e) {
      print("error: $e");
    } finally {
      _isExtracting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _service.close();
    super.dispose();
  }

  // void _close() async => await _service.close();
}
