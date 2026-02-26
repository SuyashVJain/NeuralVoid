import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../progress/controllers/progress_controller.dart';

class QuizResultScreen extends StatelessWidget {
  final String subject;
  final String chapter;
  final int score;
  final int total;

  const QuizResultScreen({
    super.key,
    required this.subject,
    required this.chapter,
    required this.score,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    double percentage = (score / total) * 100;

    // 🔥 Save full quiz result
    Provider.of<ProgressController>(context, listen: false)
        .completeQuiz(
      subject: subject,
      chapter: chapter,
      score: score,
      total: total,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz Result"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 20),

            const Text(
              "Your Performance",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 20),

            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: percentage),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, _) {
                return Text(
                  "${value.toStringAsFixed(1)}%",
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            Text("$score out of $total correct"),

            const SizedBox(height: 20),

            _buildFeedback(percentage),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(
                    context,
                    (route) => route.isFirst,
                  );
                },
                child: const Text("Back to Dashboard"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFeedback(double percentage) {
    if (percentage >= 80) {
      return const Text(
        "Excellent! You have strong mastery.",
        style: TextStyle(color: Colors.green),
      );
    } else if (percentage >= 50) {
      return const Text(
        "Good attempt. Revise and improve further.",
        style: TextStyle(color: Colors.orange),
      );
    } else {
      return const Text(
        "Needs improvement. Review the chapter.",
        style: TextStyle(color: Colors.red),
      );
    }
  }
}