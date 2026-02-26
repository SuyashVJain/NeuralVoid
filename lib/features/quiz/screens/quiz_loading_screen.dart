import 'package:flutter/material.dart';

class QuizLoadingScreen extends StatefulWidget {
  const QuizLoadingScreen({super.key});

  @override
  State<QuizLoadingScreen> createState() =>
      _QuizLoadingScreenState();
}

class _QuizLoadingScreenState
    extends State<QuizLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.8,
      end: 1.1,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _animation,
              child: Icon(
                Icons.auto_awesome,
                size: 60,
                color: Theme.of(context)
                    .colorScheme
                    .primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Generating Your AI Quiz...",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Analyzing chapter concepts...",
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}