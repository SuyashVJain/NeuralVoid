import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/progress_controller.dart';

class ProgressDashboardScreen extends StatelessWidget {
  const ProgressDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ProgressController>(context);

    final subjects = [
      "Maths",
      "Science",
      "Social Science",
      "English",
      "Hindi",
    ];

    double overallAccuracy = subjects
            .map((s) => controller.getSubjectAccuracy(s))
            .reduce((a, b) => a + b) /
        subjects.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Learning Progress"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔥 Overall Performance Card
            _OverallCard(overallAccuracy: overallAccuracy),

            const SizedBox(height: 24),

            // 📚 Subject Cards
            const Text(
              "Subject Performance",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            ...subjects.map(
              (subject) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SubjectCard(
                  subject: subject,
                  accuracy: controller.getSubjectAccuracy(subject),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 🧠 Weak Areas Section
            const Text(
              "Focus Areas",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            _WeakAreaSection(controller: controller),

            const SizedBox(height: 24),

            // 🔥 Study Streak
            const _StudyStreakCard(),

            const SizedBox(height: 24),

            // 📈 Recent Activity
            const _RecentActivityCard(),
          ],
        ),
      ),
    );
  }
}

// ============================
// 🔥 Overall Card
// ============================

class _OverallCard extends StatelessWidget {
  final double overallAccuracy;

  const _OverallCard({required this.overallAccuracy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Overall Progress",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: overallAccuracy),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: value / 100,
                    minHeight: 10,
                    backgroundColor: Colors.white24,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${value.toStringAsFixed(1)}%",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================
// 📚 Subject Card
// ============================

class _SubjectCard extends StatelessWidget {
  final String subject;
  final double accuracy;

  const _SubjectCard({
    required this.subject,
    required this.accuracy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subject,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: accuracy / 100,
            minHeight: 8,
          ),
          const SizedBox(height: 6),
          Text(
            "Accuracy: ${accuracy.toStringAsFixed(1)}%",
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ============================
// 🧠 Weak Area Section
// ============================

class _WeakAreaSection extends StatelessWidget {
  final ProgressController controller;

  const _WeakAreaSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final weakChapters = controller.getWeakChapters("Maths");

    if (weakChapters.isEmpty) {
      return const Text(
        "Great job! No weak chapters detected.",
        style: TextStyle(fontSize: 14),
      );
    }

    return Column(
      children: weakChapters
          .map(
            (chapter) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(chapter.chapter),
                  Text(
                    "${chapter.accuracy.toStringAsFixed(1)}%",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

// ============================
// 🔥 Study Streak Card
// ============================

class _StudyStreakCard extends StatelessWidget {
  const _StudyStreakCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.local_fire_department,
              color: Colors.orange),
          SizedBox(width: 10),
          Text(
            "3 Day Study Streak 🔥",
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================
// 📈 Recent Activity
// ============================

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recent Activity",
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6),
          Text("• Last quiz: 80%"),
          Text("• Doubts asked today: 3"),
        ],
      ),
    );
  }
}