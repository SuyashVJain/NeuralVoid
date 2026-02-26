import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../progress/controllers/progress_controller.dart';
import '../models/quiz_question.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  final String subject;
  final String chapter;
  final List<QuizQuestion> questions;

  const QuizScreen({
    super.key,
    required this.subject,
    required this.chapter,
    required this.questions,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentIndex = 0;
  int? selectedIndex;
  bool isSubmitted = false;
  int score = 0;

  void submitAnswer() {
    if (selectedIndex == null) return;

    setState(() {
      isSubmitted = true;
    });

    bool isCorrect =
        selectedIndex == widget.questions[currentIndex].correctIndex;

    if (isCorrect) score++;

    Provider.of<ProgressController>(context, listen: false)
        .updateQuiz(
      subject: widget.subject,
      chapter: widget.chapter,
      isCorrect: isCorrect,
    );
  }

  void nextQuestion() {
    if (currentIndex < widget.questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedIndex = null;
        isSubmitted = false;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizResultScreen(
            score: score,
            total: widget.questions.length,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Question ${currentIndex + 1}/${widget.questions.length}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // Question Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                question.question,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Options
            ...List.generate(question.options.length, (index) {
              Color bgColor = Colors.grey.shade100;

              if (isSubmitted) {
                if (index == question.correctIndex) {
                  bgColor = Colors.green.shade100;
                } else if (index == selectedIndex) {
                  bgColor = Colors.red.shade100;
                }
              } else if (selectedIndex == index) {
                bgColor = Theme.of(context)
                    .colorScheme
                    .secondaryContainer;
              }

              return GestureDetector(
                onTap: isSubmitted
                    ? null
                    : () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "${String.fromCharCode(65 + index)}. ",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Text(question.options[index]),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 10),

            // Explanation
            if (isSubmitted)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Explanation: ${question.explanation}",
                  style: const TextStyle(fontSize: 14),
                ),
              ),

            const Spacer(),

            // Buttons
            if (!isSubmitted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedIndex == null
                      ? null
                      : submitAnswer,
                  child: const Text("Submit Answer"),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: nextQuestion,
                  child: Text(
                    currentIndex ==
                            widget.questions.length - 1
                        ? "Finish Quiz"
                        : "Next Question",
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}