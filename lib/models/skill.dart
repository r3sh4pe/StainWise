import 'package:hive/hive.dart';

part 'skill.g.dart';

@HiveType(typeId: 2)
class Skill extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String? description;

  @HiveField(2)
  final int strainLowerFence;

  @HiveField(3)
  final int strainUpperFence;

  @HiveField(4)
  double averageRating;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  @HiveField(7)
  final List<double> ratings;

  @HiveField(8)
  final List<DateTime> ratingTimestamps;

  @HiveField(9)
  final List<String> tags;

  @HiveField(10)
  bool isActive;

  @HiveField(11)
  int usageCount;

  Skill({
    required this.name,
    this.description,
    required this.strainLowerFence,
    required this.strainUpperFence,
    List<double>? ratings,
    List<DateTime>? ratingTimestamps,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isActive = true,
    this.usageCount = 0,
  })  : assert(strainLowerFence >= 0 && strainLowerFence <= 100,
            'Strain lower fence must be between 0 and 100'),
        assert(strainUpperFence >= 0 && strainUpperFence <= 100,
            'Strain upper fence must be between 0 and 100'),
        assert(strainLowerFence <= strainUpperFence,
            'Lower fence must not be greater than upper fence'),
        ratings = ratings ?? [],
        ratingTimestamps = ratingTimestamps ?? [],
        tags = tags ?? [],
        averageRating = 0.0,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Adds a new rating for the skill
  void addRating(double rating) {
    if (rating < 0 || rating > 5) {
      throw RangeError.range(rating, 0, 5, 'rating');
    }

    ratings.add(rating);
    ratingTimestamps.add(DateTime.now());
    _updateAverageRating();
    _updateLastModified();
  }

  /// Updates the name of the skill
  void updateName(String newName) {
    name = newName.trim();
    _updateLastModified();
  }

  /// Updates the description of the skill
  void updateDescription(String? newDescription) {
    description = newDescription?.trim();
    _updateLastModified();
  }

  /// Adds a tag to the skill
  void addTag(String tag) {
    final trimmedTag = tag.trim().toLowerCase();
    if (!tags.contains(trimmedTag)) {
      tags.add(trimmedTag);
      _updateLastModified();
    }
  }

  /// Removes a tag from the skill
  void removeTag(String tag) {
    final trimmedTag = tag.trim().toLowerCase();
    if (tags.remove(trimmedTag)) {
      _updateLastModified();
    }
  }

  /// Updates the active status of the skill
  void updateActiveStatus(bool status) {
    isActive = status;
    _updateLastModified();
  }

  /// Increments the usage count
  void incrementUsageCount() {
    usageCount++;
    _updateLastModified();
  }

  /// Gets the latest rating
  double? getLatestRating() {
    return ratings.isEmpty ? null : ratings.last;
  }

  /// Gets the latest rating timestamp
  DateTime? getLatestRatingTimestamp() {
    return ratingTimestamps.isEmpty ? null : ratingTimestamps.last;
  }

  /// Gets ratings for a specific date range
  List<MapEntry<DateTime, double>> getRatingsForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    final List<MapEntry<DateTime, double>> entries = [];

    for (var i = 0; i < ratingTimestamps.length; i++) {
      final timestamp = ratingTimestamps[i];
      if (timestamp.isAfter(startDate) && timestamp.isBefore(endDate)) {
        entries.add(MapEntry(timestamp, ratings[i]));
      }
    }

    return entries;
  }

  /// Gets the average rating for a specific date
  double? getAverageRatingForDate(DateTime date) {
    final List<double> ratingsForDate = [];

    for (var i = 0; i < ratingTimestamps.length; i++) {
      if (_isSameDay(ratingTimestamps[i], date)) {
        ratingsForDate.add(ratings[i]);
      }
    }

    if (ratingsForDate.isEmpty) return null;

    return ratingsForDate.reduce((a, b) => a + b) / ratingsForDate.length;
  }

  /// Checks if this skill is applicable for a given strain level
  bool isApplicableForStrain(int strainLevel) {
    return strainLevel >= strainLowerFence && strainLevel <= strainUpperFence;
  }

  /// Updates the last modified timestamp
  void _updateLastModified() {
    updatedAt = DateTime.now();
  }

  /// Updates the average rating
  void _updateAverageRating() {
    if (ratings.isEmpty) {
      averageRating = 0.0;
    } else {
      averageRating = ratings.reduce((a, b) => a + b) / ratings.length;
    }
  }

  /// Checks if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
