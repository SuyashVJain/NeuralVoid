// lib/services/ai_router_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ai_response_model.dart';

class AIRouterService {
  static const String _baseUrl = 'http://10.10.1.85:8000';

  static String detectSubject(String query) {
    final q = query.toLowerCase();
    if (q.contains('math') || q.contains('equation') || q.contains('number'))
      return 'Mathematics';
    if (q.contains('reaction') || q.contains('science') || q.contains('chemical'))
      return 'Science';
    if (q.contains('history') || q.contains('geography') || q.contains('civics'))
      return 'Social Science';
    return 'General';
  }

  // ── Streaming ask with mode support ─────────────────────────
  static Stream<String> askStream(String question, {bool concise = true}) async* {
    final uri = Uri.parse('$_baseUrl/ask');

    // Wrap the question with mode instruction
    final modePrefix = concise
        ? 'Answer in 3-4 bullet points only. Be brief and exam-focused.\n\n'
        : 'Give a detailed step-by-step explanation with examples, key terms bolded, '
          'common mistakes, and exam tips.\n\n';

    final modifiedQuestion = '$modePrefix$question';

    final request = http.Request('POST', uri)
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode({'question': modifiedQuestion});

    try {
      final response = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw TimeoutException('Server took too long to respond'),
      );

      if (response.statusCode != 200) {
        yield 'Error: Server returned ${response.statusCode}';
        return;
      }

      await for (final chunk in response.stream.transform(utf8.decoder)) {
        yield chunk;
      }
    } on TimeoutException {
      yield 'Error: Could not reach the AI server. Make sure your Python server is running.';
    } catch (e) {
      yield 'Error: $e';
    }
  }

  // ── One-shot (kept for compatibility) ────────────────────────
  static Future<AIResponse> generateResponse(String query,
      {bool concise = true}) async {
    final subject = detectSubject(query);
    final buffer = StringBuffer();

    await for (final chunk in askStream(query, concise: concise)) {
      buffer.write(chunk);
    }

    final fullText = buffer.toString();
    return AIResponse(subject: subject, concise: fullText, detailed: fullText);
  }
}