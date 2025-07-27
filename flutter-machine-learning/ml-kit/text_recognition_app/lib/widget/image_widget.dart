import 'dart:io';

import 'package:flutter/material.dart';

class ImageWidget extends StatelessWidget {
  final String? imagePath;
  const ImageWidget({super.key, this.imagePath});

  @override
  Widget build(BuildContext context) {
    return imagePath == null
        ? const Align(
            alignment: Alignment.center,
            child: Icon(Icons.image, size: 100),
          )
        : Image.file(File(imagePath.toString()), fit: BoxFit.contain);
  }
}
