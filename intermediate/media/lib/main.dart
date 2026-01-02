import 'package:flutter/material.dart';
import 'package:media/provider/audio_notifier.dart';
import 'package:media/screen/audio_screen.dart';
import 'package:provider/provider.dart';
import 'provider/home_provider.dart';
// import 'screen/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => HomeProvider()),
        ChangeNotifierProvider(create: (context) => AudioNotifier()),
      ],
      child: const MaterialApp(home: AudioScreen()),
    ),
  );
}
