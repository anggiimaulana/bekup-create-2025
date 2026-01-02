import 'package:flutter/material.dart';
import 'package:media/provider/video_notifier.dart';
import 'package:media/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../widget/buffer_slider_controller_widget.dart';
import '../widget/video_controller_widget.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  VideoPlayerController? controller;
  bool isVideoInitialize = false;

  void videoInitialize() async {
    final previousVideoController = controller;

    // Melalui assets
    final videoController = VideoPlayerController.asset("assets/butterfly.mp4");

    // Melalui url
    // final videoController = VideoPlayerController.networkUrl(
    //   "https://github.com/dicodingacademy/assets/releases/download/release-video/VideoDicoding.mp4",
    // );

    try {
      await videoController.initialize();
    } on Exception catch (e) {
      print('Error initializing video: $e');
    }

    if (mounted) {
      setState(() {
        controller = videoController;
        isVideoInitialize = controller!.value.isInitialized;
      });
    }

    if (isVideoInitialize) {
      final provider = context.read<VideoNotifier>();
      controller?.addListener(() {
        provider.duration = controller?.value.duration ?? Duration.zero;
        provider.position = controller?.value.position ?? Duration.zero;
        provider.isPlay = controller?.value.isPlaying ?? false;
      });
    }
  }

  @override
  void initState() {
    videoInitialize();
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Video Player Project")),
      body: Stack(
        alignment: Alignment.center,
        children: [
          isVideoInitialize
              ? AspectRatio(
                  aspectRatio: controller!.value.aspectRatio,
                  child: VideoPlayer(controller!),
                )
              : CircularProgressIndicator(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer<VideoNotifier>(
                  builder: (context, provider, child) {
                    final duration = provider.duration;
                    final position = provider.position;

                    return BufferSliderControllerWidget(
                      maxValue: duration.inSeconds.toDouble(),
                      currentValue: position.inSeconds.toDouble(),
                      minText: durationToTimeString(position),
                      maxText: durationToTimeString(duration),
                      onChanged: (value) async {
                        final newPosition = Duration(seconds: value.toInt());
                        await controller?.seekTo(newPosition);

                        await controller?.play();
                      },
                    );
                  },
                ),
                Consumer<VideoNotifier>(
                  builder: (context, provider, child) {
                    final isPlay = provider.isPlay;
                    return VideoControllerWidget(
                      onPlayTapped: () {
                        controller?.play();
                      },
                      onPauseTapped: () {
                        controller?.pause();
                      },
                      isPlay: isPlay,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
