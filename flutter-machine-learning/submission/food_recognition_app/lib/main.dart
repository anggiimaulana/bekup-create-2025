import 'package:flutter/material.dart';
import 'package:food_recognition_app/controller/image_classification_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

// Services
import 'package:food_recognition_app/service/firebase_ml_service.dart';
import 'package:food_recognition_app/service/image_inference_service.dart';
import 'package:food_recognition_app/service/image_classification_service.dart';

// Controllers
import 'package:food_recognition_app/controller/home_controller.dart';
import 'package:food_recognition_app/controller/gallery_prediction_controller.dart';

// UI
import 'package:food_recognition_app/ui/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Firebase ML Service - singleton
        Provider<FirebaseMlService>(
          create: (_) => FirebaseMlService(),
          lazy: false,
        ),

        // Image Inference Service - depends on FirebaseMlService
        ProxyProvider<FirebaseMlService, ImageInferenceService>(
          update: (_, firebaseMl, previous) =>
              previous ?? ImageInferenceService(firebaseMl),
        ),

        // Image Classification Service - depends on FirebaseMlService
        ProxyProvider<FirebaseMlService, ImageClassificationService>(
          update: (_, firebaseMl, previous) =>
              previous ?? ImageClassificationService(firebaseMl),
        ),

        // Gallery Prediction Controller - depends on ImageInferenceService
        ChangeNotifierProxyProvider<
          ImageInferenceService,
          GalleryPredictionController
        >(
          create: (context) {
            final inferenceService = Provider.of<ImageInferenceService>(
              context,
              listen: false,
            );
            return GalleryPredictionController(inferenceService);
          },
          update: (_, inferenceService, controller) {
            if (controller == null) {
              return GalleryPredictionController(inferenceService);
            }
            // Update the service reference if needed
            controller.updateInferenceService(inferenceService);
            return controller;
          },
        ),

        // Image Classification ViewModel - depends on ImageClassificationService
        ChangeNotifierProxyProvider<
          ImageClassificationService,
          ImageClassificationViewmodel
        >(
          create: (context) {
            final classificationService =
                Provider.of<ImageClassificationService>(context, listen: false);
            return ImageClassificationViewmodel(classificationService);
          },
          update: (_, classificationService, viewmodel) {
            if (viewmodel == null) {
              return ImageClassificationViewmodel(classificationService);
            }
            return viewmodel;
          },
        ),

        // Home Controller - depends on GalleryPredictionController
        ChangeNotifierProxyProvider<
          GalleryPredictionController,
          HomeController
        >(
          create: (context) {
            final galleryController = Provider.of<GalleryPredictionController>(
              context,
              listen: false,
            );
            return HomeController(galleryController);
          },
          update: (_, galleryController, homeController) {
            if (homeController == null) {
              return HomeController(galleryController);
            }
            // Update the gallery controller reference if needed
            homeController.updateGalleryController(galleryController);
            return homeController;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Food Recognition App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}
