import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'progress/controllers/progress_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // 🔥 TEMP: Reset corrupted Hive data (run once)
  if (await Hive.boxExists('progressBox')) {
    await Hive.deleteBoxFromDisk('progressBox');
  }

  await Hive.openBox('progressBox');

  runApp(const NeuralLearnApp());
}

class NeuralLearnApp extends StatelessWidget {
  const NeuralLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
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
        home: const OnboardingScreen(),
      ),
    );
  }
}