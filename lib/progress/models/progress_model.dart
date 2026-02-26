class ChapterProgress {
  final String subject;
  final String chapter;

  int quizAttempts;
  int correctAnswers;
  int doubtsAsked;
  DateTime lastStudied;

  ChapterProgress({
    required this.subject,
    required this.chapter,
    this.quizAttempts = 0,
    this.correctAnswers = 0,
    this.doubtsAsked = 0,
    DateTime? lastStudied,
  }) : lastStudied = lastStudied ?? DateTime.now();

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
      'lastStudied': lastStudied.toIso8601String(),
    };
  }

  factory ChapterProgress.fromMap(Map map) {
    return ChapterProgress(
      subject: map['subject'],
      chapter: map['chapter'],
      quizAttempts: map['quizAttempts'],
      correctAnswers: map['correctAnswers'],
      doubtsAsked: map['doubtsAsked'],
      lastStudied: DateTime.parse(map['lastStudied']),
    );
  }
}