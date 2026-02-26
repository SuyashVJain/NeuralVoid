import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/onboarding_screen.dart';

void main() {
  runApp(const NeuralLearnApp());
}

class NeuralLearnApp extends StatelessWidget {
  const NeuralLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NeuralLearn',
      theme: AppTheme.lightTheme,
      home: const OnboardingScreen(),
    );
  }
}