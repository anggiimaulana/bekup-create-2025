import 'package:chatbot_app/controller/gemini_controller.dart';
import 'package:chatbot_app/controller/photo_controller.dart';
import 'package:chatbot_app/service/gemini_service.dart';
import 'package:chatbot_app/service/image_picker_service.dart';
import 'package:chatbot_app/ui/chat_page.dart';
import 'package:chatbot_app/ui/image_selected_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => ImagePickerService()),
        ChangeNotifierProvider(
          create: (context) => PhotoController(context.read()),
        ),
        Provider(create: (context) => GeminiService()),
        ChangeNotifierProvider(
          create: (context) => GeminiController(context.read()),
          lazy: false,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: ChatPage.path,
      routes: {
        ChatPage.path: (_) => const ChatPage(),
        ImageSelectedPage.path: (_) => const ImageSelectedPage(),
      },
    );
  }
}
