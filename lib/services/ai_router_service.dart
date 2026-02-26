import '../models/ai_response_model.dart';

class AIRouterService {
  static String detectSubject(String query) {
    final lowerQuery = query.toLowerCase();

    if (lowerQuery.contains("math") ||
        lowerQuery.contains("equation") ||
        lowerQuery.contains("number")) {
      return "Mathematics";
    }

    if (lowerQuery.contains("reaction") ||
        lowerQuery.contains("science") ||
        lowerQuery.contains("chemical")) {
      return "Science";
    }

    if (lowerQuery.contains("history") ||
        lowerQuery.contains("geography") ||
        lowerQuery.contains("civics")) {
      return "Social Science";
    }

    return "General";
  }

  static AIResponse generateResponse(String query) {
    final subject = detectSubject(query);

    return AIResponse(
      subject: subject,
      concise:
          "Concise Explanation:\n\nThis is a board-oriented explanation for \"$query\" under $subject.",
      detailed:
          "Detailed Explanation:\n\nHere we would provide a step-by-step concept breakdown, examples, common mistakes, and exam insights for \"$query\" under $subject.",
    );
  }
}