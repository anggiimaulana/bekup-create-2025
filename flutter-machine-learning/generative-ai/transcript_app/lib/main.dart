import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:transcript_app/controller/audio_controller.dart';
import 'package:transcript_app/controller/gemini_controller.dart';
import 'package:transcript_app/service/gemini_service.dart';
import 'package:transcript_app/ui/home_page.dart';
import 'package:transcript_app/ui/transcript_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AudioController()),
        Provider(create: (context) => GeminiService()),
        ChangeNotifierProvider(
          create: (context) => GeminiController(context.read()),
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
      ),
      initialRoute: HomePage.route,
      routes: {
        HomePage.route: (_) => HomePage(),
        TranscriptPage.route: (_) => TranscriptPage(),
      },
    );
  }
}
