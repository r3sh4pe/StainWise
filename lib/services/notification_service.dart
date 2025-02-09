import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

import '../models/app_settings.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  Future<void> init() async {
    try {
      await AwesomeNotifications().initialize(
        null, // null means use default app icon
        [
          NotificationChannel(
            channelKey: 'strain_wise_notifications',
            channelName: 'Strain Monitor Notifications',
            channelDescription: 'Notifications for strain monitoring reminders',
            defaultColor: Colors.blue,
            ledColor: Colors.blue,
            importance: NotificationImportance.High,
            channelShowBadge: true,
            enableVibration: true,
            playSound: true,
          )
        ],
        debug: true,
      );
    } catch (e) {
      debugPrint('Failed to initialize notifications: $e');
      // Don't rethrow - let the app continue without notifications
    }
  }

  Future<bool> requestPermissions() async {
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      return await AwesomeNotifications()
          .requestPermissionToSendNotifications();
    }
    return isAllowed;
  }

  Future<void> scheduleDailyNotification({
    required TimeOfDay notificationTime,
    required AppSettings settings,
  }) async {
    // Cancel any existing notifications
    await cancelAllNotifications();

    if (!settings.notificationsEnabled) return;

    // Create a DateTime for today with the specified time
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      notificationTime.hour,
      notificationTime.minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0,
        channelKey: 'strain_wise_notifications',
        title: 'Time to check in',
        body: 'How are you feeling? Tap to record your current strain level.',
        payload: {'type': 'strain_entry'},
        category: NotificationCategory.Reminder,
      ),
      schedule: NotificationCalendar(
        hour: notificationTime.hour,
        minute: notificationTime.minute,
        second: 0,
        millisecond: 0,
        repeats: true,
      ),
    );
  }

  Future<void> showImmediateNotification({
    required String title,
    required String body,
    Map<String, String>? payload,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecond,
        channelKey: 'strain_wise_notifications',
        title: title,
        body: body,
        payload: payload,
      ),
    );
  }

  Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  /// Set up notification action handlers
  static Future<void> onNotificationDisplayed(
      ReceivedNotification receivedNotification) async {
    // Handle displayed notification
  }

  static Future<void> onNotificationCreated(
      ReceivedNotification receivedNotification) async {
    // Handle created notification
  }

  static Future<void> onDismissActionReceived(
      ReceivedAction receivedAction) async {
    // Handle dismissed notification
  }

  static Future<void> onActionReceived(ReceivedAction receivedAction) async {
    // Handle notification action
    // You can navigate to specific screens based on the payload
    if (receivedAction.payload?['type'] == 'strain_entry') {
      // TODO: Navigate to strain entry form
    }
  }

  /// Check if notifications are allowed
  Future<bool> checkPermissions() async {
    return await AwesomeNotifications().isNotificationAllowed();
  }

  /// Initialize notification listeners
  static Future<void> initializeNotificationListeners() async {
    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceived,
      onNotificationCreatedMethod: onNotificationCreated,
      onNotificationDisplayedMethod: onNotificationDisplayed,
      onDismissActionReceivedMethod: onDismissActionReceived,
    );
  }
}
