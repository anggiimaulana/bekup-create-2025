import 'dart:io';

import 'package:chatbot_app/controller/gemini_controller.dart';
import 'package:chatbot_app/controller/image_selected_controller.dart';
import 'package:chatbot_app/controller/photo_controller.dart';
import 'package:chatbot_app/widget/text_field_sender.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ImageSelectedPage extends StatelessWidget {
  static const path = "/image";

  const ImageSelectedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('ImageSelectedPage'),
      ),
      body: SafeArea(
        child: ChangeNotifierProvider(
          create: (_) => ImageSelectedController(),
          child: _ImageSelectedBody(),
        ),
      ),
    );
  }
}

class _ImageSelectedBody extends StatelessWidget {
  const _ImageSelectedBody();

  @override
  Widget build(BuildContext context) {
    final padding = const EdgeInsets.symmetric(vertical: 4, horizontal: 8);
    return Stack(
      children: [
        Consumer2<PhotoController, ImageSelectedController>(
          builder: (_, photo, imageSelected, _) {
            final paths = photo.paths;
            if (paths == null) return SizedBox();

            final path = paths[imageSelected.imageIndex];
            return Positioned.fill(child: Image.file(File(path)));
          },
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Column(
            children: [
              SizedBox(
                height: 70,
                child: Consumer<PhotoController>(
                  builder: (_, photo, _) {
                    final paths = photo.paths;
                    if (paths == null) return SizedBox();

                    return CarouselView.weighted(
                      flexWeights: [1, 1, 1],
                      children: paths
                          .map(
                            (path) => Image.file(File(path), fit: BoxFit.cover),
                          )
                          .toList(),
                      onTap: (index) =>
                          context.read<ImageSelectedController>().imageIndex =
                              index,
                    );
                  },
                ),
              ),
              Padding(
                padding: padding,
                child: TextFieldSender(
                  sendOnPressed: (message) {
                    final gemini = context.read<GeminiController>();
                    final photo = context.read<PhotoController>();
                    final navigator = Navigator.of(context);

                    gemini.sendMessage(message, photo.paths!);
                    navigator.pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
