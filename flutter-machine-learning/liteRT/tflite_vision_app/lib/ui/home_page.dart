import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tflite_vision_app/controller/image_classification_provider.dart';
import 'package:tflite_vision_app/service/image_classification_service.dart';
import 'package:tflite_vision_app/widget/camera_view.dart';
import 'package:tflite_vision_app/widget/classification_item.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Image Classification App'),
      ),
      body: ColoredBox(
        color: Colors.black,
        child: Center(
          child: MultiProvider(
            providers: [
              Provider(create: (context) => ImageClassificationService()),
              ChangeNotifierProvider(
                create: (context) => ImageClassificationViewModel(
                  context.read<ImageClassificationService>(),
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

class _HomeBody extends StatefulWidget {
  const _HomeBody();

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  late final readViewModel = context.read<ImageClassificationViewModel>();

  @override
  void initState() {
    Future.microtask(() async => readViewModel.close());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CameraView(
          onImage: (cameraImage) async {
            await readViewModel.runClassification(cameraImage);
          },
        ),

        Positioned(
          child: Consumer<ImageClassificationViewModel>(
            builder: (_, updateViewModel, _) {
              final classifications = updateViewModel.classifications.entries;

              if (classifications.isEmpty) {
                return const SizedBox.shrink();
              }

              return SingleChildScrollView(
                child: Column(
                  children: classifications
                      .map(
                        (classifications) => ClassificatioinItem(
                          item: classifications.key,
                          value: classifications.value.toStringAsFixed(2),
                        ),
                      )
                      .toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
