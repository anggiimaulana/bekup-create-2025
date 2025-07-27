import 'package:flutter/material.dart';

class AudioControllerWidget extends StatelessWidget {
  final Function() playOnPressed;
  final Function() pauseOnPressed;
  final Function() stopOnPressed;
  final bool isPlay;

  const AudioControllerWidget({
    super.key,
    required this.playOnPressed,
    required this.pauseOnPressed,
    required this.stopOnPressed,
    required this.isPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.play_arrow),
          onPressed: isPlay ? null : playOnPressed,
        ),
        IconButton(
          icon: Icon(Icons.pause),
          onPressed: isPlay ? pauseOnPressed : null,
        ),
        IconButton(
          icon: Icon(Icons.stop),
          onPressed: isPlay ? stopOnPressed : null,
        ),
      ],
    );
  }
}
