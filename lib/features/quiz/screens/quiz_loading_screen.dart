import 'package:flutter/material.dart';

class QuizLoadingScreen extends StatefulWidget {
  final Future<void> onComplete;

  const QuizLoadingScreen({super.key, required this.onComplete});

  @override
  State<QuizLoadingScreen> createState() =>
      _QuizLoadingScreenState();
}

class _QuizLoadingScreenState
    extends State<QuizLoadingScreen> {
  double progress = 0;

  @override
  void initState() {
    super.initState();
    simulateLoading();
  }

  void simulateLoading() async {
    for (int i = 0; i <= 100; i++) {
      await Future.delayed(
          const Duration(milliseconds: 20));
      setState(() {
        progress = i / 100;
      });
    }

    await widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Text(
              "Generating Your AI Quiz",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 30),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
            ),
            const SizedBox(height: 10),
            Text(
              "${(progress * 100).toInt()}%",
            ),
          ],
        ),
      ),
    );
  }
}