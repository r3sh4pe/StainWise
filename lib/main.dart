import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:strain_wise/theme/theme_constants.dart';

import 'models/app_settings.dart';
import 'models/skill.dart';
import 'models/strain_entry.dart';
import 'models/symptom.dart';
import 'models/time_of_day_adapter.dart';
import 'pages/home_page.dart';
import 'services/notification_service.dart';
import 'services/settings_service.dart';
import 'theme/theme_provider.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'viewmodels/skill_viewmodel.dart';
import 'viewmodels/strain_entry_viewmodel.dart';
import 'viewmodels/symptom_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive Adapters
  Hive.registerAdapter(SymptomAdapter());
  Hive.registerAdapter(SkillAdapter());
  Hive.registerAdapter(StrainEntryAdapter());
  Hive.registerAdapter(AppSettingsAdapter());
  Hive.registerAdapter(TimeOfDayAdapter());

  // Initialize Services
  final settingsService = SettingsService();
  await settingsService.init();

  final notificationService = NotificationService();
  await notificationService.init();
  await NotificationService.initializeNotificationListeners();

  // Create ViewModel instances
  final symptomViewModel = SymptomViewModel();
  await symptomViewModel.init();

  final skillViewModel = SkillViewModel();
  await skillViewModel.init();

  final strainEntryViewModel = StrainEntryViewModel();
  await strainEntryViewModel.init();

  final settingsViewModel = SettingsViewModel();
  await settingsViewModel.init();

  runApp(MyApp(
    symptomViewModel: symptomViewModel,
    skillViewModel: skillViewModel,
    strainEntryViewModel: strainEntryViewModel,
    settingsViewModel: settingsViewModel,
  ));
}

class MyApp extends StatelessWidget {
  final SymptomViewModel symptomViewModel;
  final SkillViewModel skillViewModel;
  final StrainEntryViewModel strainEntryViewModel;
  final SettingsViewModel settingsViewModel;

  const MyApp({
    super.key,
    required this.symptomViewModel,
    required this.skillViewModel,
    required this.strainEntryViewModel,
    required this.settingsViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: symptomViewModel),
        ChangeNotifierProvider.value(value: skillViewModel),
        ChangeNotifierProvider.value(value: strainEntryViewModel),
        ChangeNotifierProvider.value(value: settingsViewModel),
      ],
      child: Consumer2<ThemeProvider, SettingsViewModel>(
        builder: (context, themeProvider, settingsViewModel, _) {
          // Set initial theme from settings
          if (themeProvider.currentVariant.name !=
              settingsViewModel.settings.theme) {
            themeProvider.setThemeVariant(
              ThemeVariant.values.firstWhere(
                (v) => v.name == settingsViewModel.settings.theme,
              ),
            );
          }

          return MaterialApp(
            debugShowCheckedModeBanner: false,

            // App Title
            onGenerateTitle: (context) =>
                AppLocalizations.of(context)!.appTitle,

            // Theme
            theme: themeProvider.getTheme(),

            // Localization
            locale: Locale(settingsViewModel.settings.locale),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('de'), // German
            ],

            // Error handling
            builder: (context, child) {
              // Set up top-level error handling if needed
              ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Something went wrong!',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                );
              };

              return ScrollConfiguration(
                behavior: ScrollBehavior().copyWith(
                  physics: const BouncingScrollPhysics(),
                ),
                child: child!,
              );
            },

            // Home Page
            home: const HomePage(),
          );
        },
      ),
    );
  }
}