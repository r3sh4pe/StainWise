import 'package:hive/hive.dart';

part 'symptom.g.dart';

@HiveType(typeId: 1)
class Symptom extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String? description;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  DateTime updatedAt;

  @HiveField(4)
  final List<int> strainLevels;

  @HiveField(5)
  final List<DateTime> strainTimestamps;

  @HiveField(6)
  bool isActive;

  @HiveField(7)
  int frequency; // Count of how often this symptom was recorded

  @HiveField(8)
  int averageStrainLevel; // Average strain level for quick access

  Symptom({
    required this.name,
    this.description,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<int>? strainLevels,
    List<DateTime>? strainTimestamps,
    this.isActive = true,
    this.frequency = 0,
    this.averageStrainLevel = 0,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        strainLevels = strainLevels ?? [],
        strainTimestamps = strainTimestamps ?? [];

  /// Adds a new strain level entry
  void addStrainLevel(int level) {
    if (level < 0 || level > 100) {
      throw RangeError.range(level, 0, 100, 'strainLevel');
    }

    strainLevels.add(level);
    strainTimestamps.add(DateTime.now());
    frequency++;
    _updateAverageStrainLevel();
    _updateLastModified();
  }

  /// Updates the name of the symptom
  void updateName(String newName) {
    name = newName.trim();
    _updateLastModified();
  }

  /// Updates the description of the symptom
  void updateDescription(String? newDescription) {
    description = newDescription?.trim();
    _updateLastModified();
  }

  /// Updates the active status of the symptom
  void updateActiveStatus(bool status) {
    isActive = status;
    _updateLastModified();
  }

  /// Gets the latest strain level
  int? getLatestStrainLevel() {
    return strainLevels.isEmpty ? null : strainLevels.last;
  }

  /// Gets the latest strain timestamp
  DateTime? getLatestStrainTimestamp() {
    return strainTimestamps.isEmpty ? null : strainTimestamps.last;
  }

  /// Gets strain entries for a specific date range
  List<MapEntry<DateTime, int>> getStrainEntriesForDateRange(
      DateTime startDate,
      DateTime endDate,
      ) {
    final List<MapEntry<DateTime, int>> entries = [];

    for (var i = 0; i < strainTimestamps.length; i++) {
      final timestamp = strainTimestamps[i];
      if (timestamp.isAfter(startDate) && timestamp.isBefore(endDate)) {
        entries.add(MapEntry(timestamp, strainLevels[i]));
      }
    }

    return entries;
  }

  /// Gets the average strain level for a specific date
  double? getAverageStrainLevelForDate(DateTime date) {
    final List<int> levelsForDate = [];

    for (var i = 0; i < strainTimestamps.length; i++) {
      if (_isSameDay(strainTimestamps[i], date)) {
        levelsForDate.add(strainLevels[i]);
      }
    }

    if (levelsForDate.isEmpty) return null;

    return levelsForDate.reduce((a, b) => a + b) / levelsForDate.length;
  }

  /// Updates the last modified timestamp
  void _updateLastModified() {
    updatedAt = DateTime.now();
  }

  /// Updates the average strain level
  void _updateAverageStrainLevel() {
    if (strainLevels.isEmpty) {
      averageStrainLevel = 0;
    } else {
      averageStrainLevel = strainLevels.reduce((a, b) => a + b) ~/ strainLevels.length;
    }
  }

  /// Checks if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}