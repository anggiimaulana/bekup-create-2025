import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:text_recognition_app/service/text_recognition_service.dart';

class ResultProvider extends ChangeNotifier {
  final TextRecognitionService _service;

  ResultProvider([TextRecognitionService? service])
    : _service = service ?? TextRecognitionService();

  String? detectedText;
  bool isProcessing = false;

  void runTextRecognition(String path) async {
    detectedText = null;
    isProcessing = true;
    notifyListeners();

    detectedText = await _service.runRecognizedText(path);
    isProcessing = false;
    notifyListeners();
  }

  void copyText(BuildContext context) async {
    if (detectedText == null) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final clipBoardData = ClipboardData(text: detectedText!);
    await Clipboard.setData(clipBoardData);

    scaffoldMessenger.showSnackBar(SnackBar(content: Text("Copied to Clipboard")));
  }
}
