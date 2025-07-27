import 'package:flutter/material.dart';

class TranscriptItem extends StatelessWidget {
  final String speakerName;
  final String timecode;
  final String caption;
  final Function()? onTapped;

  const TranscriptItem({
    super.key,
    required this.speakerName,
    required this.timecode,
    required this.caption,
    this.onTapped,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTapped,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Speaker $speakerName",
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(timecode, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            Text(caption, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
