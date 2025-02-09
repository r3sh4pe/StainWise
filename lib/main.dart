import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/skill.dart';
import 'models/strain_entry.dart';
import 'models/symptom.dart';
import 'pages/home_page.dart';
import 'theme/theme_provider.dart';
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

  // Create ViewModel instances
  final symptomViewModel = SymptomViewModel();
  await symptomViewModel.init();

  final skillViewModel = SkillViewModel();
  await skillViewModel.init();

  final strainEntryViewModel = StrainEntryViewModel();
  await strainEntryViewModel.init();

  runApp(MyApp(
    symptomViewModel: symptomViewModel,
    skillViewModel: skillViewModel,
    strainEntryViewModel: strainEntryViewModel,
  ));
}

class MyApp extends StatelessWidget {
  final SymptomViewModel symptomViewModel;
  final SkillViewModel skillViewModel;
  final StrainEntryViewModel strainEntryViewModel;

  const MyApp({
    super.key,
    required this.symptomViewModel,
    required this.skillViewModel,
    required this.strainEntryViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: symptomViewModel),
        ChangeNotifierProvider.value(value: skillViewModel),
        ChangeNotifierProvider.value(value: strainEntryViewModel),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,

            // App Title
            onGenerateTitle: (context) =>
                AppLocalizations.of(context)!.appTitle,

            // Theme
            theme: themeProvider.getTheme(),

            // Localization
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
