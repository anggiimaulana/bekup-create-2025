import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:text_recognition_app/controller/home_provider.dart';
import 'package:text_recognition_app/widget/image_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Text Recognition App'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: const _HomeBody(),
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => context.read<HomeProvider>().openGallery(),
            child: Consumer<HomeProvider>(
              builder: (context, value, child) {
                final imagePath = value.imagePath;
                return ImageWidget(imagePath: imagePath);
              },
            ),
          ),
        ),
        Consumer<HomeProvider>(
          builder: (context, value, child) {
            return FilledButton.tonal(
              onPressed: value.imagePath == null
                  ? null
                  : () => value.goToResultPage(context),
              child: const Text("Analyze"),
            );
          },
        ),
      ],
    );
  }
}
