import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/home_provider.dart';
import 'screen/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => HomeProvider(),
      child: const MaterialApp(home: HomePage()),
    ),
  );
}
