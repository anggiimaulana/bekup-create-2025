import 'package:flutter/material.dart';
import 'package:food_recognition_app/controller/image/image_classification_provider.dart';
import 'package:food_recognition_app/controller/meal/meal_detail_controller.dart';
import 'package:food_recognition_app/controller/ml/ml_service_manager.dart';
import 'package:food_recognition_app/service/meal_db_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

// Services
import 'package:food_recognition_app/service/firebase_ml_service.dart';
import 'package:food_recognition_app/service/image_inference_service.dart';
import 'package:food_recognition_app/service/image_classification_service.dart';

// Controllers
import 'package:food_recognition_app/controller/home/home_controller.dart';
import 'package:food_recognition_app/controller/gallery/gallery_prediction_controller.dart';

// UI
import 'package:food_recognition_app/ui/home/home_page.dart';

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

        ChangeNotifierProvider<MLServiceManager>(
          create: (_) => MLServiceManager(),
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

        // Services
        Provider<MealDbService>(
          create: (_) => MealDbService(),
          dispose: (_, service) {
            // Service doesn't need disposal
          },
        ),

        // Meal Detail Controller (created when needed)
        ProxyProvider<MealDbService, MealDetailController>(
          create: (_) => throw UnimplementedError(),
          update: (_, mealDbService, previous) {
            if (previous != null) {
              return previous;
            }
            return MealDetailController(mealDbService);
          },
          dispose: (_, controller) => controller.dispose(),
        ),
      ],
      child: MaterialApp(
        title: 'Food Recognition App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const AppInitializer(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

/// Widget yang handle initialization dan routing
class AppInitializer extends StatefulWidget {
  const AppInitializer({Key? key}) : super(key: key);

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();

    // Start ML services initialization immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMLServices();
    });
  }

  Future<void> _initializeMLServices() async {
    try {
      final mlManager = context.read<MLServiceManager>();

      // Initialize with retry mechanism and timeout
      await mlManager.initializeWithRetry(
        maxRetries: 2,
        timeout: const Duration(seconds: 30),
      );

      // Optional: Warm up services
      await mlManager.warmUpServices();
    } catch (e) {
      debugPrint('Failed to initialize ML services: $e');

      // Show error dialog
      if (mounted) {
        _showInitializationError(e.toString());
      }
    }
  }

  void _showInitializationError(String error) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Initialization Error'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Failed to load AI model:\n$error',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initializeMLServices(); // Retry
            },
            child: const Text('Retry'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Could exit app or show limited functionality
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main app content
          const HomePage(),

          // ML initialization overlay
          const MLInitializationOverlay(),
        ],
      ),
    );
  }
}
