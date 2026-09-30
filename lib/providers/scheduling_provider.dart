import 'package:flutter/material.dart';
import '../reminder/reminder_service.dart';

class SchedulingProvider extends ChangeNotifier {
  bool _isScheduled = false;
  bool _isLoading = true;

  bool get isScheduled => _isScheduled;
  bool get isLoading => _isLoading;

  SchedulingProvider() {
    _loadSchedulingStatus();
  }

  Future<void> _loadSchedulingStatus() async {
    _isLoading = true;
    notifyListeners();

    _isScheduled = await ReminderService.instance.isEnabled();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> scheduledDailyReminder(bool value) async {
    _isScheduled = value;
    notifyListeners();

    if (value) {
      await ReminderService.instance.enable();
    } else {
      await ReminderService.instance.disable();
    }

    _isScheduled = await ReminderService.instance.isEnabled();
    notifyListeners();
    return _isScheduled;
  }

  Future<void> scheduleTestReminder(Duration delay) async {
    await ReminderService.instance.scheduleTestReminder(delay);
  }
}
