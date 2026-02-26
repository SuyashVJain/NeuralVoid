// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:neural_learn/l10n/app_localizations.dart';
import 'package:neural_learn/core/theme/app_theme.dart';
import 'package:neural_learn/core/providers/locale_provider.dart';
import 'package:neural_learn/features/onboarding/onboarding_screen.dart';

void main() {
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

    return MaterialApp(
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
    );
  }
}