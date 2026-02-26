import 'package:flutter/material.dart';
import '../models/progress_model.dart';
import '../services/progress_local_service.dart';

class ProgressController extends ChangeNotifier {
  final ProgressLocalService _service = ProgressLocalService();

  List<ChapterProgress> chapters = [];

  // ==========================================================
  // LOAD PROGRESS
  // ==========================================================

  void loadProgress() {
    final data = _service.getAllChapters();
    chapters =
        data.map((e) => ChapterProgress.fromMap(e)).toList();
    notifyListeners();
  }

  // ==========================================================
  // UPDATE QUIZ PER QUESTION
  // ==========================================================

  void updateQuiz({
    required String subject,
    required String chapter,
    required bool isCorrect,
  }) {
    final key = "$subject-$chapter";

    var existing = _service.getChapter(key);

    ChapterProgress progress = existing == null
        ? ChapterProgress(subject: subject, chapter: chapter)
        : ChapterProgress.fromMap(existing);

    progress.quizAttempts++;
    if (isCorrect) {
      progress.correctAnswers++;
    }

    progress.lastStudied = DateTime.now();

    _service.saveChapter(key, progress.toMap());
    loadProgress();
  }

  // ==========================================================
  // COMPLETE QUIZ (NEW PROFESSIONAL METHOD)
  // ==========================================================

  void completeQuiz({
    required String subject,
    required String chapter,
    required int score,
    required int total,
  }) {
    final key = "$subject-$chapter";

    var existing = _service.getChapter(key);

    ChapterProgress progress = existing == null
        ? ChapterProgress(subject: subject, chapter: chapter)
        : ChapterProgress.fromMap(existing);

    double percentage = (score / total) * 100;

    // Store last quiz result
    progress.lastScore = percentage;

    // Increase total quiz sessions
    progress.totalQuizSessions++;

    progress.lastStudied = DateTime.now();

    _service.saveChapter(key, progress.toMap());
    loadProgress();
  }

  // ==========================================================
  // UPDATE DOUBT COUNT
  // ==========================================================

  void updateDoubt({
    required String subject,
    required String chapter,
  }) {
    final key = "$subject-$chapter";

    var existing = _service.getChapter(key);

    ChapterProgress progress = existing == null
        ? ChapterProgress(subject: subject, chapter: chapter)
        : ChapterProgress.fromMap(existing);

    progress.doubtsAsked++;
    progress.lastStudied = DateTime.now();

    _service.saveChapter(key, progress.toMap());
    loadProgress();
  }

  // ==========================================================
  // SUBJECT ACCURACY
  // ==========================================================

  double getSubjectAccuracy(String subject) {
    final subjectChapters =
        chapters.where((c) => c.subject == subject).toList();

    int totalAttempts = 0;
    int totalCorrect = 0;

    for (var c in subjectChapters) {
      totalAttempts += c.quizAttempts;
      totalCorrect += c.correctAnswers;
    }

    if (totalAttempts == 0) return 0;
    return (totalCorrect / totalAttempts) * 100;
  }

  // ==========================================================
  // WEAK CHAPTERS
  // ==========================================================

  List<ChapterProgress> getWeakChapters(String subject) {
    return chapters
        .where((c) =>
            c.subject == subject &&
            c.quizAttempts > 0 &&
            c.accuracy < 50)
        .toList();
  }

  // ==========================================================
  // GET LAST QUIZ SCORE
  // ==========================================================

  double getLastQuizScore(String subject, String chapter) {
    final chapterData = chapters.firstWhere(
      (c) =>
          c.subject == subject && c.chapter == chapter,
      orElse: () =>
          ChapterProgress(subject: subject, chapter: chapter),
    );

    return chapterData.lastScore;
  }

  // ==========================================================
  // MASTERY LEVEL (AI STYLE)
  // ==========================================================

  String getMasteryLevel(String subject, String chapter) {
    final chapterData = chapters.firstWhere(
      (c) =>
          c.subject == subject && c.chapter == chapter,
      orElse: () =>
          ChapterProgress(subject: subject, chapter: chapter),
    );

    double accuracy = chapterData.accuracy;

    if (accuracy >= 80) {
      return "Strong";
    } else if (accuracy >= 50) {
      return "Improving";
    } else {
      return "Needs Attention";
    }
  }
}