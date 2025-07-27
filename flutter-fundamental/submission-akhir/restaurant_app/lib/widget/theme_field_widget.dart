import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/provider/setting/theme_state_provider.dart';
import 'package:restaurant_app/provider/setting/title_form_widget.dart';
import 'package:restaurant_app/utils/theme_state.dart';

class ThemeFieldWidget extends StatefulWidget {
  const ThemeFieldWidget({super.key});

  @override
  State<ThemeFieldWidget> createState() => _ThemeFieldWidgetState();
}

class _ThemeFieldWidgetState extends State<ThemeFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TitleForm('Theme Setting:'),
          const SizedBox.square(dimension: 4),
          ...ThemeState.values.map(
            (state) => Consumer<ThemeStateProvider>(
              builder: (_, provider, __) {
                return RadioListTile<ThemeState>(
                  value: state,
                  groupValue: provider.notificationState,
                  contentPadding: const EdgeInsets.all(0),
                  title: Text(state.name),
                  onChanged: (value) {
                    provider.notificationState = value!;
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
