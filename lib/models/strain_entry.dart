import 'package:hive/hive.dart';

import 'skill.dart';
import 'symptom.dart';

part 'strain_entry.g.dart';

@HiveType(typeId: 3)
class StrainEntry extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String? note;

  @HiveField(2)
  int strainLevel;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  DateTime updatedAt;

  @HiveField(5)
  final List<Symptom> symptoms;

  @HiveField(6)
  Skill? usedSkill;

  @HiveField(7)
  double? skillRating;

  @HiveField(8)
  bool isSkillRated;

  @HiveField(9)
  DateTime? skillRatedAt;

  StrainEntry({
    required this.title,
    this.note,
    required this.strainLevel,
    List<Symptom>? symptoms,
    this.usedSkill,
    this.skillRating,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : assert(strainLevel >= 0 && strainLevel <= 100,
            'Strain level must be between 0 and 100'),
        assert(skillRating == null || (skillRating >= 0 && skillRating <= 5),
            'Skill rating must be between 0 and 5'),
        symptoms = symptoms ?? [],
        isSkillRated = skillRating != null,
        skillRatedAt = skillRating != null ? DateTime.now() : null,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Updates the title of the entry
  void updateTitle(String newTitle) {
    title = newTitle.trim();
    _updateLastModified();
  }

  /// Updates the note of the entry
  void updateNote(String? newNote) {
    note = newNote?.trim();
    _updateLastModified();
  }

  /// Updates the strain level
  void updateStrainLevel(int newLevel) {
    if (newLevel < 0 || newLevel > 100) {
      throw RangeError.range(newLevel, 0, 100, 'strainLevel');
    }
    strainLevel = newLevel;
    _updateLastModified();
  }

  /// Adds a symptom to the entry
  void addSymptom(Symptom symptom) {
    if (!symptoms.contains(symptom)) {
      symptoms.add(symptom);
      _updateLastModified();
    }
  }

  /// Removes a symptom from the entry
  void removeSymptom(Symptom symptom) {
    if (symptoms.remove(symptom)) {
      _updateLastModified();
    }
  }

  /// Sets or updates the used skill
  void setSkill(Skill skill) {
    usedSkill = skill;
    isSkillRated = false;
    skillRating = null;
    skillRatedAt = null;
    _updateLastModified();
  }

  /// Rates the used skill
  void rateSkill(double rating) {
    if (usedSkill == null) {
      throw StateError('Cannot rate skill: no skill is set');
    }
    if (rating < 0 || rating > 5) {
      throw RangeError.range(rating, 0, 5, 'rating');
    }

    skillRating = rating;
    isSkillRated = true;
    skillRatedAt = DateTime.now();
    usedSkill?.addRating(rating);
    _updateLastModified();
  }

  /// Checks if the entry needs a skill rating
  bool get needsSkillRating => usedSkill != null && !isSkillRated;

  /// Gets the time elapsed since creation
  Duration get age => DateTime.now().difference(createdAt);

  /// Gets the time elapsed since last update
  Duration get timeSinceUpdate => DateTime.now().difference(updatedAt);

  /// Gets a short summary of the entry
  String getSummary() {
    final parts = <String>[
      'Strain: $strainLevel',
      if (symptoms.isNotEmpty) 'Symptoms: ${symptoms.length}',
      if (usedSkill != null) 'Skill: ${usedSkill!.name}',
      if (skillRating != null) 'Rated: $skillRating/5',
    ];
    return parts.join(' | ');
  }

  /// Updates the last modified timestamp
  void _updateLastModified() {
    updatedAt = DateTime.now();
  }
}
