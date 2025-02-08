import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Belastungsmonitor';

  @override
  String get strainLevel => 'Belastungsniveau';

  @override
  String get strainNote => 'Notiz';

  @override
  String get createEntry => 'Eintrag erstellen';

  @override
  String get skillName => 'Fähigkeitsname';

  @override
  String get skillDescription => 'Beschreibung';

  @override
  String get symptomName => 'Symptomname';

  @override
  String get symptomDescription => 'Beschreibung';

  @override
  String get rateSkill => 'Fähigkeit bewerten';

  @override
  String get unratedEntries => 'Unbewertete Einträge';

  @override
  String get settings => 'Einstellungen';

  @override
  String get notificationInterval => 'Benachrichtigungsintervall';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get minutes => 'Minuten';
}
