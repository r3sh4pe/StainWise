import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/skill.dart';

class SkillViewModel extends ChangeNotifier {
  late final Box<Skill> _skillBox;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Skill> get skills => _skillBox.values.toList();
  List<Skill> get activeSkills => _skillBox.values.where((s) => s.isActive).toList();

  // Initialize the ViewModel
  Future<void> init() async {
    _setLoading(true);
    try {
      _skillBox = await Hive.openBox<Skill>('skills');
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to initialize skills: $e';
      debugPrint('Error initializing SkillViewModel: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create a new skill
  Future<void> createSkill({
    required String name,
    String? description,
    required int strainLowerFence,
    required int strainUpperFence,
    List<String>? tags,
  }) async {
    _setLoading(true);
    try {
      final skill = Skill(
        name: name.trim(),
        description: description?.trim(),
        strainLowerFence: strainLowerFence,
        strainUpperFence: strainUpperFence,
        tags: tags,
      );
      await _skillBox.add(skill);
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to create skill: $e';
      debugPrint('Error creating skill: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing skill
  Future<void> updateSkill(
      Skill skill, {
        String? name,
        String? description,
        bool? isActive,
        List<String>? tags,
      }) async {
    _setLoading(true);
    try {
      if (name != null) skill.updateName(name);
      if (description != null) skill.updateDescription(description);
      if (isActive != null) skill.updateActiveStatus(isActive);
      if (tags != null) {
        skill.tags.clear();
        skill.tags.addAll(tags.map((tag) => tag.trim().toLowerCase()));
      }

      await skill.save();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update skill: $e';
      debugPrint('Error updating skill: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Add a rating to a skill
  Future<void> addRating(Skill skill, double rating) async {
    _setLoading(true);
    try {
      skill.addRating(rating);
      await skill.save();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add rating: $e';
      debugPrint('Error adding rating: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Increment usage count
  Future<void> incrementUsage(Skill skill) async {
    _setLoading(true);
    try {
      skill.incrementUsageCount();
      await skill.save();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to increment usage: $e';
      debugPrint('Error incrementing usage: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a skill
  Future<void> deleteSkill(Skill skill) async {
    _setLoading(true);
    try {
      await skill.delete();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete skill: $e';
      debugPrint('Error deleting skill: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Get a skill by its key
  Skill? getSkillByKey(dynamic key) {
    try {
      return _skillBox.get(key);
    } catch (e) {
      _errorMessage = 'Failed to get skill: $e';
      debugPrint('Error getting skill: $e');
      return null;
    }
  }

  // Get skills by tag
  List<Skill> getSkillsByTag(String tag) {
    final normalizedTag = tag.trim().toLowerCase();
    return skills.where((skill) =>
        skill.tags.contains(normalizedTag)
    ).toList();
  }

  // Get applicable skills for a strain level
  List<Skill> getSkillsForStrainLevel(int strainLevel) {
    return activeSkills.where((skill) =>
        skill.isApplicableForStrain(strainLevel)
    ).toList();
  }

  // Get skills sorted by average rating
  List<Skill> getSkillsSortedByRating({bool descending = true}) {
    final sortedSkills = List<Skill>.from(activeSkills);
    sortedSkills.sort((a, b) => descending
        ? b.averageRating.compareTo(a.averageRating)
        : a.averageRating.compareTo(b.averageRating)
    );
    return sortedSkills;
  }

  // Get skills sorted by usage count
  List<Skill> getSkillsSortedByUsage({bool descending = true}) {
    final sortedSkills = List<Skill>.from(activeSkills);
    sortedSkills.sort((a, b) => descending
        ? b.usageCount.compareTo(a.usageCount)
        : a.usageCount.compareTo(b.usageCount)
    );
    return sortedSkills;
  }

  // Get all unique tags
  Set<String> get allTags {
    return skills.expand((skill) => skill.tags).toSet();
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
    _skillBox.compact();
    _skillBox.close();
    super.dispose();
  }
}