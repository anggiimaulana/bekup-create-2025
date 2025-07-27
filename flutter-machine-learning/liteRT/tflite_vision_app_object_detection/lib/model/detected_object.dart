import 'package:flutter/widgets.dart';

class DetectedObject {
  int id;
  Rect rect;
  num score;
  String label;
  DetectedObject({
    required this.id,
    required this.rect,
    required this.score,
    required this.label,
  });
}
