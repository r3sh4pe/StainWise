import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Strain Monitor';

  @override
  String get strainLevel => 'Strain Level';

  @override
  String get strainNote => 'Note';

  @override
  String get createEntry => 'Create Entry';

  @override
  String get skillName => 'Skill Name';

  @override
  String get skillDescription => 'Description';

  @override
  String get symptomName => 'Symptom Name';

  @override
  String get symptomDescription => 'Description';

  @override
  String get rateSkill => 'Rate Skill';

  @override
  String get unratedEntries => 'Unrated Entries';

  @override
  String get settings => 'Settings';

  @override
  String get notificationInterval => 'Notification Interval';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get minutes => 'Minutes';
}
