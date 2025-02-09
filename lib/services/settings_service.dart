import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/app_settings.dart';
import '../models/time_of_day_adapter.dart';
import 'notification_service.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();

  factory SettingsService() => _instance;

  SettingsService._internal();

  static const String _boxName = 'settings';
  static const String _settingsKey = 'app_settings';

  late Box<AppSettings> _settingsBox;
  final NotificationService _notificationService = NotificationService();

  /// Initialize the settings service
  Future<void> init() async {
    // Ensure Hive is initialized
    await Hive.initFlutter();

    // Register the TimeOfDay adapter if not already registered
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(TimeOfDayAdapter());
    }

    // Open the settings box
    _settingsBox = await Hive.openBox<AppSettings>(_boxName);

    // Initialize notification service
    await _notificationService.init();

    // Create default settings if none exist
    if (!_settingsBox.containsKey(_settingsKey)) {
      await _settingsBox.put(_settingsKey, AppSettings());
    }
  }

  /// Get the current settings
  AppSettings getSettings() {
    return _settingsBox.get(_settingsKey) ?? AppSettings();
  }

  /// Update the language setting
  Future<void> updateLocale(String locale) async {
    final settings = getSettings();
    settings.locale = locale;
    await _settingsBox.put(_settingsKey, settings);
  }

  /// Update the theme setting
  Future<void> updateTheme(String theme) async {
    final settings = getSettings();
    settings.theme = theme;
    await _settingsBox.put(_settingsKey, settings);
  }

  /// Update notification settings
  Future<void> updateNotifications(bool enabled) async {
    final settings = getSettings();
    settings.notificationsEnabled = enabled;
    await _settingsBox.put(_settingsKey, settings);

    // Handle notification permissions and scheduling
    if (enabled) {
      final hasPermission = await _notificationService.requestPermissions();
      if (!hasPermission) {
        settings.notificationsEnabled = false;
        await _settingsBox.put(_settingsKey, settings);
        throw Exception('Notification permissions denied');
      }
    } else {
      await _notificationService.cancelAllNotifications();
    }
  }

  /// Update sleep time settings
  Future<void> updateSleepTime(TimeOfDay start, TimeOfDay end) async {
    final settings = getSettings();
    settings.sleepTimeStart = start;
    settings.sleepTimeEnd = end;
    await _settingsBox.put(_settingsKey, settings);

    // Reschedule notifications if enabled
    if (settings.notificationsEnabled) {
      // TODO: Implement notification rescheduling
    }
  }

  /// Check if a given time is within sleep hours
  bool isInSleepTime(TimeOfDay time) {
    final settings = getSettings();
    return settings.isInSleepTime(time);
  }

  /// Reset settings to default
  Future<void> resetSettings() async {
    final defaultSettings = AppSettings();
    await _settingsBox.put(_settingsKey, defaultSettings);

    // Cancel all notifications when resetting
    await _notificationService.cancelAllNotifications();
  }

  /// Get list of available themes
  List<String> getAvailableThemes() {
    return ['latte', 'frappe', 'macchiato', 'mocha'];
  }

  /// Get list of available locales
  List<Locale> getAvailableLocales() {
    return const [
      Locale('en'),
      Locale('de'),
    ];
  }

  /// Close and clean up resources
  Future<void> dispose() async {
    await _settingsBox.compact();
    await _settingsBox.close();
  }
}
