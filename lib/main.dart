import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'models/symptom.dart';
import 'models/skill.dart';
import 'theme/theme_provider.dart';
import 'viewmodels/symptom_viewmodel.dart';
import 'viewmodels/skill_viewmodel.dart';
import 'pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive Adapters
  Hive.registerAdapter(SymptomAdapter());
  Hive.registerAdapter(SkillAdapter());

  // Create ViewModel instances
  final symptomViewModel = SymptomViewModel();
  await symptomViewModel.init();

  final skillViewModel = SkillViewModel();
  await skillViewModel.init();

  runApp(MyApp(
    symptomViewModel: symptomViewModel,
    skillViewModel: skillViewModel,
  ));
}

class MyApp extends StatelessWidget {
  final SymptomViewModel symptomViewModel;
  final SkillViewModel skillViewModel;

  const MyApp({
    super.key,
    required this.symptomViewModel,
    required this.skillViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: symptomViewModel),
        ChangeNotifierProvider.value(value: skillViewModel),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,

            // App Title
            onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,

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