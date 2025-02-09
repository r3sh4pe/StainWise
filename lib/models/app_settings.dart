import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 4)
class AppSettings extends HiveObject {
  @HiveField(0)
  String locale;

  @HiveField(1)
  String theme;

  @HiveField(2)
  bool notificationsEnabled;

  @HiveField(3)
  TimeOfDay sleepTimeStart;

  @HiveField(4)
  TimeOfDay sleepTimeEnd;

  AppSettings({
    this.locale = 'en',
    this.theme = 'macchiato',
    this.notificationsEnabled = false,
    TimeOfDay? sleepTimeStart,
    TimeOfDay? sleepTimeEnd,
  })  : sleepTimeStart = sleepTimeStart ?? const TimeOfDay(hour: 22, minute: 0),
        sleepTimeEnd = sleepTimeEnd ?? const TimeOfDay(hour: 8, minute: 0);

  // Custom adapters for TimeOfDay since Hive can't store it directly
  Map<String, int> encodeTimeOfDay(TimeOfDay time) {
    return {
      'hour': time.hour,
      'minute': time.minute,
    };
  }

  TimeOfDay decodeTimeOfDay(Map<String, int> map) {
    return TimeOfDay(
      hour: map['hour'] ?? 0,
      minute: map['minute'] ?? 0,
    );
  }

  bool isInSleepTime(TimeOfDay currentTime) {
    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    final startMinutes = sleepTimeStart.hour * 60 + sleepTimeStart.minute;
    final endMinutes = sleepTimeEnd.hour * 60 + sleepTimeEnd.minute;

    if (startMinutes <= endMinutes) {
      // Sleep time doesn't cross midnight
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    } else {
      // Sleep time crosses midnight
      return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
    }
  }

  String getReadableTimeRange() {
    final startFormatted = _formatTime(sleepTimeStart);
    final endFormatted = _formatTime(sleepTimeEnd);
    return '$startFormatted - $endFormatted';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
