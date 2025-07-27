import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:transcript_app/controller/audio_controller.dart';
import 'package:transcript_app/utils/utils.dart';
import 'package:transcript_app/widget/audio_controller_widget.dart';
import 'package:transcript_app/widget/buffer_slider_controller_widget.dart';

class AudioPlayerWidget extends StatefulWidget {
  final AudioPlayer audioPlayer;

  const AudioPlayerWidget({super.key, required this.audioPlayer});

  @override
  State<AudioPlayerWidget> createState() => AudioPlayerWidgetState();
}

class AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late final Source audioSource;

  @override
  void initState() {
    super.initState();

    final provider = context.read<AudioController>();

    audioSource = AssetSource("softskill_podcast.mp3");
    widget.audioPlayer.setSource(audioSource);

    widget.audioPlayer.onPlayerStateChanged.listen((state) {
      provider.isPlay = state == PlayerState.playing;

      if (state == PlayerState.stopped) {
        provider.position = Duration.zero;
      }
    });

    widget.audioPlayer.onDurationChanged.listen((duration) {
      provider.duration = duration;
    });

    widget.audioPlayer.onPositionChanged.listen((position) {
      provider.position = position;
    });

    widget.audioPlayer.onPlayerComplete.listen((_) {
      provider.position = Duration.zero;
      provider.isPlay = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Consumer<AudioController>(
            builder: (context, provider, child) {
              final duration = provider.duration;
              final position = provider.position;

              return BufferSliderControllerWidget(
                maxValue: duration.inSeconds.toDouble(),
                currentValue: position.inSeconds.toDouble(),
                minText: durationToTime(position),
                maxText: durationToTime(duration),
                onChanged: (value) async {
                  final newPosition = Duration(seconds: value.toInt());
                  await widget.audioPlayer.seek(newPosition);

                  await widget.audioPlayer.resume();
                },
              );
            },
          ),
        ),
        Consumer<AudioController>(
          builder: (context, provider, child) {
            final bool isPlay = provider.isPlay;
            return AudioControllerWidget(
              playOnPressed: () => widget.audioPlayer.play(audioSource),
              pauseOnPressed: () => widget.audioPlayer.pause(),
              stopOnPressed: () => widget.audioPlayer.stop(),
              isPlay: isPlay,
            );
          },
        ),
      ],
    );
  }
}
