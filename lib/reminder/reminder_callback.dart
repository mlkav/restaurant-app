import 'dart:convert';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';

import 'reminder_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, _) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();

      if (!dotenv.isInitialized) {
        await dotenv.load(
          fileName: ".env",
          isOptional: true,
          mergeWith: {
            'BASE_URL': 'https://restaurant-api.dicoding.dev',
            'IMAGE_BASE_URL': 'https://restaurant-api.dicoding.dev/images',
          },
        );
      }

      await ReminderService.instance.initNotificationOnly();

      final baseUrl = dotenv.get(
        'BASE_URL',
        fallback: 'https://restaurant-api.dicoding.dev',
      );
      final response = await http.get(Uri.parse('$baseUrl/list'));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final list = decoded['restaurants'] as List;
        if (list.isNotEmpty) {
          final restaurant = list[Random().nextInt(list.length)];

          await ReminderService.instance.showNotification(
            title: 'Waktunya Makan 🍽️',
            body: '${restaurant['name']} - ${restaurant['city']}',
            restaurantId: restaurant['id'],
          );
        }
      }

      if (task == 'daily_reminder_task') {
        final isEnabled = await ReminderService.instance.isEnabled();
        if (isEnabled) {
          await ReminderService.instance.enable();
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  });
}
