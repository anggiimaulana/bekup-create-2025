import 'package:chatbot_app/model/chat.dart';
import 'package:chatbot_app/service/gemini_service.dart';
import 'package:flutter/widgets.dart';

class GeminiController extends ChangeNotifier {
  final GeminiService service;

  GeminiController(this.service);

  final List<Chat> _historyChats = [];

  List<Chat> get historyChats => _historyChats.reversed.toList();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> sendMessage(String message, [List<String>? paths]) async {
    _historyChats.add(Chat(text: message, isMyChat: true, paths: paths));
    _isLoading = true;
    notifyListeners();

    final response = await service.sendMessage(message, _historyChats, paths);

    _historyChats.add(Chat(text: response, isMyChat: false));
    _isLoading = false;
    notifyListeners();
  }
}
