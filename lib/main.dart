// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:neural_learn/l10n/app_localizations.dart';
import 'package:neural_learn/core/theme/app_theme.dart';
import 'package:neural_learn/core/providers/locale_provider.dart';
import 'package:neural_learn/features/onboarding/onboarding_screen.dart';
import 'package:neural_learn/progress/controllers/progress_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // 🔥 TEMP: Reset corrupted Hive data (run once)
  if (await Hive.boxExists('progressBox')) {
    await Hive.deleteBoxFromDisk('progressBox');
  }
  await Hive.openBox('progressBox');

  runApp(
    ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: const NeuralLearnApp(),
    ),
  );
}

class NeuralLearnApp extends StatelessWidget {
  const NeuralLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final controller = ProgressController();
            controller.loadProgress();
            return controller;
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'NeuralLearn',
        theme: AppTheme.lightTheme,
        locale: localeProvider.locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('hi'),
        ],
        home: const OnboardingScreen(),
      ),
    );
  }
}