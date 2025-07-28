import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:tflite_vision_app_object_detection/model/detected_object.dart';

// todo-03-ui-01: create a painter
class ObjectDetectorPainter extends CustomPainter {
  // todo-03-ui-02: add constructor and list of detected object property, dont forget the shouldRepaint method
  final List<DetectedObject> objects;

  ObjectDetectorPainter(this.objects);

  @override
  void paint(Canvas canvas, Size size) {
    // todo-03-ui-03: define the paint.
    final Paint paint1 = Paint()
      ..strokeWidth = 5.0
      ..color = Colors.red;

    // todo-03-ui-04: loop every property inside object
    for (var object in objects) {
      var rect = object.rect;
      final score = object.score;
      final label = object.label;
      final text = "$label: ${(score * 100).toStringAsFixed(1)}%";

      // todo-03-ui-05: define the proper rect
      final left = _translateX(rect.left, size);
      final top = _translateY(rect.top, size);
      final width = _translateX(rect.width, size);
      final height = _translateY(rect.height, size);
      rect = Rect.fromLTWH(left, top, width, height);

      // todo-03-ui-06: draw the rect and text
      canvas.drawRect(rect, paint1..style = PaintingStyle.stroke);

      final paragraphStyle = ui.ParagraphStyle(
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );
      final textStyle = ui.TextStyle(
        color: Colors.white,
        background: paint1..style = PaintingStyle.fill,
        fontSize: 12,
      );
      final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle)
        ..pushStyle(textStyle)
        ..addText(text);
      final paragraphConstraints = ui.ParagraphConstraints(
        width: (rect.right - rect.left).abs(),
      );
      final paragraph = paragraphBuilder.build()..layout(paragraphConstraints);

      canvas.drawParagraph(paragraph, Offset(rect.left, rect.top));
    }
  }

  double _translateX(double x, Size canvasSize) => x * canvasSize.width / 300;

  double _translateY(double y, Size canvasSize) => y * canvasSize.height / 300;

  @override
  bool shouldRepaint(ObjectDetectorPainter oldDelegate) {
    return oldDelegate.objects != objects;
  }
}
