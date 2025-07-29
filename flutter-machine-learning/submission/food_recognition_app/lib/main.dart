import 'package:flutter/material.dart';
import 'package:food_recognition_app/controller/home_controller.dart';
import 'package:food_recognition_app/controller/image_classification_provider.dart';
import 'package:food_recognition_app/service/firebase_ml_service.dart';
import 'package:food_recognition_app/service/image_classification_service.dart';
import 'package:food_recognition_app/ui/home_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // Tambahkan import Firebase

void main() async {
  // Inisialisasi Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (context) => FirebaseMlService()),
        Provider(
          create: (context) =>
              ImageClassificationService(context.read<FirebaseMlService>()),
        ),
        ChangeNotifierProvider(create: (context) => HomeController()),
        ChangeNotifierProvider(
          create: (context) => ImageClassificationViewmodel(
            context.read<ImageClassificationService>(),
          ),
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
      title: 'Food Recognition App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
