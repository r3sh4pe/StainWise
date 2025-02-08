import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/symptom.dart';

class SymptomViewModel extends ChangeNotifier {
  late final Box<Symptom> _symptomBox;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Symptom> get symptoms => _symptomBox.values.toList();
  List<Symptom> get activeSymptoms => _symptomBox.values.where((s) => s.isActive).toList();

  // Initialize the ViewModel
  Future<void> init() async {
    _setLoading(true);
    try {
      _symptomBox = await Hive.openBox<Symptom>('symptoms');
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to initialize symptoms: $e';
      debugPrint('Error initializing SymptomViewModel: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create a new symptom
  Future<void> createSymptom({
    required String name,
    String? description,
  }) async {
    _setLoading(true);
    try {
      final symptom = Symptom(
        name: name.trim(),
        description: description?.trim(),
      );
      await _symptomBox.add(symptom);
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to create symptom: $e';
      debugPrint('Error creating symptom: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing symptom
  Future<void> updateSymptom(
      Symptom symptom, {
        String? name,
        String? description,
        bool? isActive,
      }) async {
    _setLoading(true);
    try {
      if (name != null) symptom.updateName(name);
      if (description != null) symptom.updateDescription(description);
      if (isActive != null) symptom.updateActiveStatus(isActive);

      await symptom.save();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update symptom: $e';
      debugPrint('Error updating symptom: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add a strain level to a symptom
  Future<void> addStrainLevel(Symptom symptom, int level) async {
    _setLoading(true);
    try {
      symptom.addStrainLevel(level);
      await symptom.save();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add strain level: $e';
      debugPrint('Error adding strain level: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Delete a symptom
  Future<void> deleteSymptom(Symptom symptom) async {
    _setLoading(true);
    try {
      await symptom.delete();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete symptom: $e';
      debugPrint('Error deleting symptom: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get a symptom by its key
  Symptom? getSymptomByKey(dynamic key) {
    try {
      return _symptomBox.get(key);
    } catch (e) {
      _errorMessage = 'Failed to get symptom: $e';
      debugPrint('Error getting symptom: $e');
      return null;
    }
  }

  // Get symptoms for a specific date range
  List<Symptom> getSymptomsWithStrainInDateRange(DateTime startDate, DateTime endDate) {
    return symptoms
        .where((symptom) => symptom.getStrainEntriesForDateRange(startDate, endDate).isNotEmpty)
        .toList();
  }

  // Get average strain level for all symptoms on a specific date
  double? getAverageStrainLevelForDate(DateTime date) {
    final List<double> averages = symptoms
        .map((s) => s.getAverageStrainLevelForDate(date))
        .where((avg) => avg != null)
        .cast<double>()
        .toList();

    if (averages.isEmpty) return null;
    return averages.reduce((a, b) => a + b) / averages.length;
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
    _symptomBox.compact();
    _symptomBox.close();
    super.dispose();
  }
}