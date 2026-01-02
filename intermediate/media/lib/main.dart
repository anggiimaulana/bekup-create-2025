import 'package:flutter/material.dart';
import 'package:media/data/api/api_service.dart';
import 'package:media/provider/audio_notifier.dart';
import 'package:media/provider/upload_provider.dart';
import 'package:media/provider/video_notifier.dart';
import 'package:media/screen/home_screen.dart';
// import 'package:media/screen/audio_screen.dart';
// import 'package:media/screen/video_screen.dart';
import 'package:provider/provider.dart';
import 'provider/home_provider.dart';
// import 'screen/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => HomeProvider()),
        ChangeNotifierProvider(
          create: (context) => UploadProvider(ApiService()),
        ),
        ChangeNotifierProvider(create: (context) => AudioNotifier()),
        ChangeNotifierProvider(create: (context) => VideoNotifier()),
      ],
      child: const MaterialApp(home: HomePage()),
    ),
  );
}
