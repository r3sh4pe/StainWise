import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'models/symptom.dart';
import 'theme/theme_provider.dart';
import 'viewmodels/symptom_viewmodel.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive Adapters
  Hive.registerAdapter(SymptomAdapter());

  // Create ViewModel instances
  final symptomViewModel = SymptomViewModel();
  await symptomViewModel.init();

  runApp(MyApp(symptomViewModel: symptomViewModel));
}

class MyApp extends StatelessWidget {
  final SymptomViewModel symptomViewModel;

  const MyApp({
    super.key,
    required this.symptomViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: symptomViewModel),
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

            // Home Page
            home: const HomePage(),
          );
        },
      ),
    );
  }
}