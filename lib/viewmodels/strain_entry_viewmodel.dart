import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/skill.dart';
import '../models/strain_entry.dart';
import '../models/symptom.dart';

class StrainEntryViewModel extends ChangeNotifier {
  late final Box<StrainEntry> _entryBox;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  List<StrainEntry> get entries => _entryBox.values.toList();

  List<StrainEntry> get unratedEntries =>
      entries.where((entry) => entry.needsSkillRating).toList();

  // Initialize the ViewModel
  Future<void> init() async {
    _setLoading(true);
    try {
      _entryBox = await Hive.openBox<StrainEntry>('strain_entries');
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to initialize strain entries: $e';
      debugPrint('Error initializing StrainEntryViewModel: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create a new strain entry
  Future<void> createEntry({
    required String title,
    String? note,
    required int strainLevel,
    List<Symptom>? symptoms,
    Skill? usedSkill,
  }) async {
    _setLoading(true);
    try {
      final entry = StrainEntry(
        title: title.trim(),
        note: note?.trim(),
        strainLevel: strainLevel,
        symptoms: symptoms,
        usedSkill: usedSkill,
      );

      await _entryBox.add(entry);

      // Update usage count for the skill if used
      if (usedSkill != null) {
        usedSkill.incrementUsageCount();
        await usedSkill.save();
      }

      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to create entry: $e';
      debugPrint('Error creating strain entry: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing entry
  Future<void> updateEntry(
    StrainEntry entry, {
    String? title,
    String? note,
    int? strainLevel,
    List<Symptom>? symptoms,
    Skill? usedSkill,
  }) async {
    _setLoading(true);
    try {
      if (title != null) entry.updateTitle(title);
      if (note != null) entry.updateNote(note);
      if (strainLevel != null) entry.updateStrainLevel(strainLevel);
      if (symptoms != null) {
        entry.symptoms.clear();
        entry.symptoms.addAll(symptoms);
      }
      if (usedSkill != null) entry.setSkill(usedSkill);

      await entry.save();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update entry: $e';
      debugPrint('Error updating strain entry: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Rate a skill for an entry
  Future<void> rateSkill(StrainEntry entry, double rating) async {
    _setLoading(true);
    try {
      entry.rateSkill(rating);
      await entry.save();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to rate skill: $e';
      debugPrint('Error rating skill: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Delete an entry
  Future<void> deleteEntry(StrainEntry entry) async {
    _setLoading(true);
    try {
      await entry.delete();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete entry: $e';
      debugPrint('Error deleting strain entry: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Get entries for a specific date
  List<StrainEntry> getEntriesForDate(DateTime date) {
    return entries
        .where((entry) =>
            entry.createdAt.year == date.year &&
            entry.createdAt.month == date.month &&
            entry.createdAt.day == date.day)
        .toList();
  }

  // Get entries within a date range
  List<StrainEntry> getEntriesForDateRange(DateTime start, DateTime end) {
    return entries
        .where((entry) =>
            entry.createdAt.isAfter(start) && entry.createdAt.isBefore(end))
        .toList();
  }

  // Get entries with specific symptoms
  List<StrainEntry> getEntriesWithSymptoms(List<Symptom> symptoms) {
    return entries
        .where((entry) => entry.symptoms.any((s) => symptoms.contains(s)))
        .toList();
  }

  // Get entries using a specific skill
  List<StrainEntry> getEntriesUsingSkill(Skill skill) {
    return entries.where((entry) => entry.usedSkill?.key == skill.key).toList();
  }

  // Get average strain level for a date
  double? getAverageStrainForDate(DateTime date) {
    final dayEntries = getEntriesForDate(date);
    if (dayEntries.isEmpty) return null;

    final sum =
        dayEntries.fold<int>(0, (prev, entry) => prev + entry.strainLevel);
    return sum / dayEntries.length;
  }

  // Get most effective skills (based on rating and strain reduction)
  List<Skill> getMostEffectiveSkills({int limit = 5}) {
    final ratedEntries = entries.where((e) => e.skillRating != null);
    final skillEffectiveness = <Skill, List<double>>{};

    for (var entry in ratedEntries) {
      if (entry.usedSkill != null && entry.skillRating != null) {
        skillEffectiveness.putIfAbsent(entry.usedSkill!, () => []);
        skillEffectiveness[entry.usedSkill!]!.add(entry.skillRating!);
      }
    }

    final sortedSkills = skillEffectiveness.entries.toList()
      ..sort((a, b) {
        final aAvg = a.value.reduce((a, b) => a + b) / a.value.length;
        final bAvg = b.value.reduce((a, b) => a + b) / b.value.length;
        return bAvg.compareTo(aAvg);
      });

    return sortedSkills.take(limit).map((e) => e.key).toList();
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

  // Dispose of resources
  @override
  void dispose() {
    _entryBox.compact();
    _entryBox.close();
    super.dispose();
  }
}
