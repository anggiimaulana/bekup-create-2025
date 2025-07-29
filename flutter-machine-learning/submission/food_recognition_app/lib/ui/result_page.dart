import 'package:flutter/material.dart';
import 'package:food_recognition_app/widget/classification_item.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blueAccent,
        title: const Text('Result Page', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(child: const _ResultBody()),
    );
  }
}

class _ResultBody extends StatefulWidget {
  const _ResultBody();

  @override
  State<_ResultBody> createState() => _ResultBodyState();
}

class _ResultBodyState extends State<_ResultBody> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // todo-02: run the inference model based on user picture
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Expanded(
          child: Center(
            child: Image.network(
              "https://github.com/dicodingacademy/assets/raw/refs/heads/main/flutter_ml/assets/nasi-lemak.jpg",
              fit: BoxFit.cover,
            ),
          ),
        ),
        // todo-03: show the inference result (food name and the confidence score)
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: ClassificationItem(item: "Nasi Lemak", value: "89.58%"),
        ),
      ],
    );
  }
}
