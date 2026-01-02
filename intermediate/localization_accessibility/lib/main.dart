import 'package:flutter/material.dart';
import 'package:localization_accessibility/common.dart';
import 'package:localization_accessibility/home.dart';
import 'package:localization_accessibility/localizations_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LocalizationsProvider>(
      create: (context) => LocalizationsProvider(),
      builder: (context, child) {
        final provider = Provider.of<LocalizationsProvider>(context);
        return MaterialApp(
          title: 'Flutter Localization & Accessibility',
          theme: ThemeData(
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            scaffoldBackgroundColor: Colors.grey.shade50,
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey.shade800,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: provider.locale,
          home: const HomePage(),
        );
      },
    );
  }
}
