import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/app_settings.dart';

class SettingsViewModel extends ChangeNotifier {
  static const String _boxName = 'settings';
  static const String _settingsKey = 'app_settings';

  late final Box<AppSettings> _settingsBox;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  late AppSettings _settings;

  AppSettings get settings => _settings;

  // Initialize the ViewModel
  Future<void> init() async {
    _setLoading(true);
    try {
      _settingsBox = await Hive.openBox<AppSettings>(_boxName);

      // Load or create settings
      _settings = _settingsBox.get(_settingsKey) ?? AppSettings();
      await _settingsBox.put(_settingsKey, _settings);

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to initialize settings: $e';
      debugPrint('Error initializing SettingsViewModel: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update language
  Future<void> updateLocale(String locale) async {
    _setLoading(true);
    try {
      _settings.locale = locale;
      await _settings.save();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update language: $e';
      debugPrint('Error updating language: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Update theme
  Future<void> updateTheme(String theme) async {
    _setLoading(true);
    try {
      _settings.theme = theme;
      await _settings.save();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update theme: $e';
      debugPrint('Error updating theme: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Update notifications enabled
  Future<void> updateNotificationsEnabled(bool enabled) async {
    _setLoading(true);
    try {
      _settings.notificationsEnabled = enabled;
      await _settings.save();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update notifications setting: $e';
      debugPrint('Error updating notifications setting: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Update sleep time range
  Future<void> updateSleepTimeRange(TimeOfDay start, TimeOfDay end) async {
    _setLoading(true);
    try {
      _settings.sleepTimeStart = start;
      _settings.sleepTimeEnd = end;
      await _settings.save();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update sleep time: $e';
      debugPrint('Error updating sleep time: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Check if notifications should be shown
  bool shouldShowNotification() {
    if (!_settings.notificationsEnabled) return false;

    final now = TimeOfDay.now();
    return !_settings.isInSleepTime(now);
  }

  // Get available themes
  List<String> getAvailableThemes() {
    return ['latte', 'frappe', 'macchiato', 'mocha'];
  }

  // Get available locales
  List<Locale> getAvailableLocales() {
    return const [
      Locale('en'),
      Locale('de'),
    ];
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Reset settings to default
  Future<void> resetToDefault() async {
    _setLoading(true);
    try {
      _settings = AppSettings();
      await _settings.save();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to reset settings: $e';
      debugPrint('Error resetting settings: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Dispose of resources
  @override
  void dispose() {
    _settingsBox.compact();
    _settingsBox.close();
    super.dispose();
  }
}
