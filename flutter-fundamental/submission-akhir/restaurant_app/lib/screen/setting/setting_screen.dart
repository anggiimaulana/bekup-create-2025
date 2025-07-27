import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/data/model/setting/setting.dart';
import 'package:restaurant_app/provider/local/local_notification_provider.dart';
import 'package:restaurant_app/provider/local/shared_preferences_provider.dart';
import 'package:restaurant_app/provider/setting/daily_reminder_state_provider.dart';
import 'package:restaurant_app/provider/setting/theme_state_provider.dart';
import 'package:restaurant_app/widget/save_button_widget.dart';
import 'package:restaurant_app/widget/theme_field_widget.dart';
import 'package:restaurant_app/style/colors/restaurant_color.dart';
import 'package:restaurant_app/utils/theme_state.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationStateProvider = context.read<ThemeStateProvider>();
      final sharedPreferencesProvider = context
          .read<SharedPreferencesProvider>();

      sharedPreferencesProvider.getSettingValue();
      final setting = sharedPreferencesProvider.setting;
      if (setting != null) {
        notificationStateProvider.notificationState = setting.themeMode
            ? ThemeState.lightTheme
            : ThemeState.darkTheme;

        context.read<DailyReminderStateProvider>().isEnabled =
            setting.dailyReminderEnabled;
      }
    });
  }

  void saveAction() async {
    final themeState = context.read<ThemeStateProvider>().notificationState;
    final isThemeEnable = themeState.isLight;
    final isDailyReminderEnable = context
        .read<DailyReminderStateProvider>()
        .isEnabled;

    final Setting setting = Setting(
      themeMode: isThemeEnable,
      dailyReminderEnabled: isDailyReminderEnable,
    );

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final sharedPreferencesProvider = context.read<SharedPreferencesProvider>();
    await sharedPreferencesProvider.saveSettingValue(setting);

    scaffoldMessenger.showSnackBar(
      SnackBar(content: Text(sharedPreferencesProvider.message)),
    );
  }

  Future<void> _scheduleDailyTenAmNotification() async {
    context.read<LocalNotificationProvider>().scheduleDailyTenAMNotification();
  }

  Future<void> _checkPendingNotificationRequests() async {
    final localNotificationProvider = context.read<LocalNotificationProvider>();
    await localNotificationProvider.checkPendingNotificationRequests(context);

    if (!mounted) return;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        final pendingData = context.select(
          (LocalNotificationProvider provider) =>
              provider.pendingNotificationRequests,
        );
        return AlertDialog(
          title: Text(
            '${pendingData.length} pending notification requests',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          content: SizedBox(
            height: 300,
            width: 300,
            child: ListView.builder(
              itemCount: pendingData.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final item = pendingData[index];
                return ListTile(
                  title: Text(
                    item.title ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    item.body ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  contentPadding: EdgeInsets.zero,
                  trailing: IconButton(
                    onPressed: () {
                      localNotificationProvider
                        ..cancelNotification(item.id)
                        ..checkPendingNotificationRequests(context);
                    },
                    icon: const Icon(Icons.delete_outline),
                  ),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Text(
          "Setting",
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(color: Colors.white),
        ),
        backgroundColor: RestaurantColor.blue.color,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Activate Daily Reminder"),
                  Consumer<DailyReminderStateProvider>(
                    builder: (context, provider, _) => Switch(
                      value: provider.isEnabled,
                      onChanged: (value) {
                        provider.isEnabled = value;

                        if (value) {
                          _scheduleDailyTenAmNotification();
                        } else {
                          context
                              .read<LocalNotificationProvider>()
                              .cancelNotification(3);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () async {
                  await _scheduleDailyTenAmNotification();
                },
                child: const Text(
                  "Schedule daily 11:00:00 am notification",
                  textAlign: TextAlign.center,
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _checkPendingNotificationRequests();
                },
                child: const Text(
                  "Check pending notifications",
                  textAlign: TextAlign.center,
                ),
              ),
              const ThemeFieldWidget(),
              SaveButton(onPressed: () => saveAction()),
            ],
          ),
        ),
      ),
    );
  }
}
