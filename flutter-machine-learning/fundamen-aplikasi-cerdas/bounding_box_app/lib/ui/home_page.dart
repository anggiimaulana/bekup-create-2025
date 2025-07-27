import 'package:bounding_box_app/model/detected_object.dart';
import 'package:bounding_box_app/utils/bounding_box_custom_painter.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  List<DetectedObject> get detectedObjects => [
    DetectedObject(
      rect: const Rect.fromLTRB(98, 23, 248, 215),
      text: "Laptop",
      confidenceScore: 0.64,
    ),
    DetectedObject(
      rect: const Rect.fromLTRB(255, 103, 288, 154),
      text: "Cell Phone",
      confidenceScore: 0.57,
    ),
    DetectedObject(
      rect: const Rect.fromLTRB(257, 158, 320, 219),
      text: "Cup",
      confidenceScore: 0.60,
    ),
    DetectedObject(
      rect: const Rect.fromLTRB(110, 120, 238, 175),
      text: "Keyboard",
      confidenceScore: 0.48,
    ),
    DetectedObject(
      rect: const Rect.fromLTRB(5, 114, 100, 210),
      text: "Note",
      confidenceScore: 0.43,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomPaint(
              foregroundPainter: BoundingBoxCustomPainter(
                detectedObjects: detectedObjects,
              ),
              child: Image.asset(
                "assets/macbook-air.jpg",
                fit: BoxFit.cover,
                width: 350,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
