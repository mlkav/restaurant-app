import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'reminder_callback.dart';

const _taskName = 'daily_reminder_task';
const _prefKey = 'daily_reminder_active';

class ReminderService {
  ReminderService._();
  static final instance = ReminderService._();

  final FlutterLocalNotificationsPlugin _notification =
      FlutterLocalNotificationsPlugin();

  GlobalKey<NavigatorState>? _navigatorKey;
  bool _initialized = false;

  Future<void> init(GlobalKey<NavigatorState> navigatorKey) async {
    if (_initialized) return;
    _navigatorKey = navigatorKey;

    await initNotificationOnly();

    final launchDetails = await _notification.getNotificationAppLaunchDetails();

    if (launchDetails?.didNotificationLaunchApp ?? false) {
      final id = launchDetails!.notificationResponse?.payload;
      if (id != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navigatorKey?.currentState?.pushNamed('/detail', arguments: id);
        });
      }
    }

    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

    _initialized = true;
  }

  Future<void> initNotificationOnly() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _notification.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final id = response.payload;
        if (id != null) {
          _navigatorKey?.currentState?.pushNamed('/detail', arguments: id);
        }
      },
    );
  }

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  Future<void> enable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, true);
    await _schedule();
  }

  Future<void> disable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, false);
    await Workmanager().cancelAll();
  }

  /// SCHEDULER
  Future<void> _schedule() async {
    await Workmanager().registerOneOffTask(
      'daily_${DateTime.now().millisecondsSinceEpoch}',
      _taskName,
      initialDelay: _delayUntil11(),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  Future<void> scheduleTestReminder(Duration delay) async {
    await Workmanager().registerOneOffTask(
      'test_${DateTime.now().millisecondsSinceEpoch}',
      _taskName,
      initialDelay: delay,
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  Duration _delayUntil11() {
    final now = DateTime.now();
    final target = DateTime(now.year, now.month, now.day, 11, 0, 0);

    if (target.isAfter(now)) {
      return target.difference(now);
    }
    return target.add(const Duration(days: 1)).difference(now);
  }

  /// NOTIFICATION
  Future<void> showNotification({
    required String title,
    required String body,
    required String restaurantId,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminder',
      channelDescription: 'Daily restaurant recommendation at 11:00 AM',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notification.show(0, title, body, details, payload: restaurantId);
  }
}
