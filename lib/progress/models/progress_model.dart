class ChapterProgress {
  final String subject;
  final String chapter;

  int quizAttempts;
  int correctAnswers;
  int doubtsAsked;

  double lastScore;
  int totalQuizSessions;

  DateTime? lastStudied;

  ChapterProgress({
    required this.subject,
    required this.chapter,
    this.quizAttempts = 0,
    this.correctAnswers = 0,
    this.doubtsAsked = 0,
    this.lastScore = 0,
    this.totalQuizSessions = 0,
    this.lastStudied,
  });

  double get accuracy {
    if (quizAttempts == 0) return 0;
    return (correctAnswers / quizAttempts) * 100;
  }

  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'chapter': chapter,
      'quizAttempts': quizAttempts,
      'correctAnswers': correctAnswers,
      'doubtsAsked': doubtsAsked,
      'lastScore': lastScore,
      'totalQuizSessions': totalQuizSessions,
      'lastStudied': lastStudied?.millisecondsSinceEpoch,
    };
  }

  factory ChapterProgress.fromMap(Map<String, dynamic> map) {
    return ChapterProgress(
      subject: map['subject']?.toString() ?? '',
      chapter: map['chapter']?.toString() ?? '',

      quizAttempts: _toInt(map['quizAttempts']),
      correctAnswers: _toInt(map['correctAnswers']),
      doubtsAsked: _toInt(map['doubtsAsked']),

      lastScore: _toDouble(map['lastScore']),
      totalQuizSessions: _toInt(map['totalQuizSessions']),

      lastStudied: map['lastStudied'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              _toInt(map['lastStudied']))
          : null,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}