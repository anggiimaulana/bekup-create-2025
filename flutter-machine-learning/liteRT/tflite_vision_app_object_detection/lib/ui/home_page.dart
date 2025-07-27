import 'package:flutter/material.dart';
import 'package:tflite_vision_app_object_detection/controller/object_detection_provider.dart';
import 'package:tflite_vision_app_object_detection/service/object_detection_service.dart';
import 'package:tflite_vision_app_object_detection/utils/object_detector_painter.dart';
import 'package:tflite_vision_app_object_detection/widget/camera_view.dart';
import 'package:tflite_vision_app_object_detection/widget/classification_item.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Object Detection App'),
      ),
      body: ColoredBox(
        color: Colors.black,
        child: Center(
          // todo-05-ui-01: inject all classes
          child: MultiProvider(
            providers: [
              Provider(create: (context) => ObjectDetectionService()),
              ChangeNotifierProvider(
                create: (context) => ObjectDetectionViewmodel(
                  context.read<ObjectDetectionService>(),
                ),
              ),
            ],
            child: _HomeBody(),
          ),
        ),
      ),
    );
  }
}

// todo-05-ui-02: change this widget into StatefulWidget
class _HomeBody extends StatefulWidget {
  const _HomeBody();

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  // todo-05-ui-03: setup the provider and dispose it after using it
  late final readViewmodel = context.read<ObjectDetectionViewmodel>();

  @override
  void dispose() {
    Future.microtask(() async => await readViewmodel.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ObjectDetectionViewmodel>(
      builder: (context, value, child) {
        final detectedObjects = value.detectedObjects;

        return CustomPaint(
          foregroundPainter: ObjectDetectorPainter(detectedObjects),
          child: child,
        );
      },
      child: CameraView(
        // todo-05-ui-04: add the parameter and run the inference process
        onImage: (cameraImage) async {
          await readViewmodel.runDetection(cameraImage);
        },
      ),
    );
  }
}
