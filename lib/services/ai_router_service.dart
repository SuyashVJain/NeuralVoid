import 'dart:async';
import 'dart:math';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import '../models/ai_response_model.dart';
import 'rag_service.dart';

class AIRouterService {
  static InferenceModel? _model;
  static bool _initialized = false;
  static OnDeviceTranslator? _translator;
  static bool _translatorReady = false;

  // Conversation context memory
  static String _lastQuestion = '';
  static String _lastResponse = '';
  static String _currentTopic = ''; // tracks the main topic

  static String detectSubject(String query) {
    final q = query.toLowerCase();
    if (q.contains('math') || q.contains('equation') || q.contains('number') ||
        q.contains('theorem') || q.contains('triangle') || q.contains('pythagoras')) {
      return 'Mathematics';
    }
    if (q.contains('reaction') || q.contains('science') || q.contains('chemical') ||
        q.contains('photosynthesis') || q.contains('cell') || q.contains('atom')) {
      return 'Science';
    }
    if (q.contains('history') || q.contains('geography') || q.contains('civics')) {
      return 'Social Science';
    }
    return 'General';
  }

  static bool _isFollowUp(String query) {
    final q = query.toLowerCase().trim();
    final followUpTriggers = [
      'it', 'its', 'this', 'that', 'these', 'those',
      'formula for it', 'explain it', 'what is it',
      'give example', 'more', 'elaborate', 'why', 'how'
    ];
    final wordCount = q.split(' ').length;
    return wordCount <= 3 ||
        followUpTriggers.any((t) => q == t || q.startsWith('$t ') || q.endsWith(' $t'));
  }

  static String _buildEnrichedQuery(String question) {
    if (_isFollowUp(question)) {
      // Always enrich against the TOPIC, not the last follow-up
      final base = _currentTopic.isNotEmpty ? _currentTopic : _lastQuestion;
      if (base.isNotEmpty) {
        final enriched = '$base $question';
        print('💡 [CONTEXT] Follow-up enriched with topic: "$enriched"');
        return enriched;
      }
    } else {
      // New topic — save it
      _currentTopic = question;
      print('💡 [CONTEXT] New topic set: "$question"');
    }
    return question;
  }

  static Future<void> initialize() async {
    if (_initialized) return;
    print('🔧 [INIT] Starting Gemma model initialization...');

    await FlutterGemma.installModel(
      modelType: ModelType.gemmaIt,
    ).fromAsset('assets/model/gemma3-1B-it-int4.task').install();
    print('✅ [INIT] Gemma model installed');

    _model = await FlutterGemma.getActiveModel(
      maxTokens: 2048,
      preferredBackend: PreferredBackend.gpu,
    );
    print('✅ [INIT] Gemma model loaded into memory');

    _initialized = true;
    print('✅ [INIT] Initialization complete');

    print('📚 [INIT] Pre-loading RAG service...');
    await RagService.initialize();
    print('✅ [INIT] RAG service ready');
  }

  static Future<void> _initTranslator() async {
    if (_translatorReady) return;
    print('🌐 [TRANSLATOR] Initializing MLKit translator...');

    final modelManager = OnDeviceTranslatorModelManager();
    final downloaded = await modelManager.isModelDownloaded(
      TranslateLanguage.hindi.bcpCode,
    );
    print('🌐 [TRANSLATOR] Hindi model downloaded: $downloaded');

    if (!downloaded) {
      print('🌐 [TRANSLATOR] Downloading Hindi model (~20MB)...');
      await modelManager.downloadModel(TranslateLanguage.hindi.bcpCode);
      print('✅ [TRANSLATOR] Hindi model downloaded');
    }

    _translator = OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.english,
      targetLanguage: TranslateLanguage.hindi,
    );
    _translatorReady = true;
    print('✅ [TRANSLATOR] Translator ready');
  }

  static Future<String> _translateToHindi(String text) async {
    try {
      print('🔄 [TRANSLATE] Starting translation...');
      await _initTranslator();

      final cleaned = text
          .replaceAll('**', '')
          .replaceAll('__', '')
          .replaceAll('##', '')
          .replaceAll('# ', '');

      final chunks = cleaned
          .split('\n')
          .where((l) => l.trim().isNotEmpty)
          .toList();

      print('🔄 [TRANSLATE] Translating ${chunks.length} chunks...');
      final translatedChunks = <String>[];

      for (int i = 0; i < chunks.length; i++) {
        final translated = await _translator!.translateText(chunks[i]);
        print('🔄 [TRANSLATE] Chunk $i done: $translated');
        translatedChunks.add(translated);
      }

      final result = translatedChunks.join('\n');
      print('✅ [TRANSLATE] Full translation done');
      return result;
    } catch (e) {
      print('❌ [TRANSLATE] Error: $e');
      return text;
    }
  }

  static Stream<String> askStream(
    String question, {
    bool concise = true,
    String language = 'English',
  }) async* {
    print('💬 [ASK] Original question: $question');
    print('💬 [ASK] Language: $language | Concise: $concise');

    await initialize();

    // Build enriched query using topic context
    final enrichedQuery = _buildEnrichedQuery(question);
    print('💬 [ASK] Enriched query: $enrichedQuery');

    // RAG retrieval using enriched query
    print('🔍 [RAG] Retrieving relevant NCERT chunks...');
    final ragChunks = RagService.retrieve(enrichedQuery);
    print('🔍 [RAG] Got ${ragChunks.length} chunks');

    String ragContext = '';
    if (ragChunks.isNotEmpty) {
      ragContext = 'NCERT Context:\n${ragChunks.join('\n---\n')}\n\n';
      print('🔍 [RAG] Context length: ${ragContext.length} chars');
      print('🔍 [RAG] First chunk preview: ${ragChunks.first.substring(0, min(80, ragChunks.first.length))}...');
    } else {
      print('⚠️ [RAG] No relevant chunks found, using Gemma knowledge only');
    }

    // Include last Q&A for follow-up context in prompt
    String conversationContext = '';
    if (_lastQuestion.isNotEmpty && _isFollowUp(question)) {
      conversationContext = 'Previous Q: $_lastQuestion\nPrevious A: $_lastResponse\n\n';
      print('💡 [CONTEXT] Including previous Q&A in prompt');
    }

    final modePrefix = concise
        ? 'You are an expert NCERT tutor. Use the context below to answer in exactly 3 clear bullet points. Each bullet point must be a complete sentence.\n\n${conversationContext}${ragContext}'
        : 'You are an expert NCERT tutor. Use the context below to give a detailed explanation with examples, common mistakes to avoid, and exam tips.\n\n${conversationContext}${ragContext}';

    print('💬 [ASK] Final prompt length: ${(modePrefix + question).length} chars');
    print('💬 [ASK] Sending prompt to Gemma...');

    final session = await _model!.createSession();

    try {
      await session.addQueryChunk(
        Message.text(text: '$modePrefix$question', isUser: true),
      );
      print('💬 [ASK] Waiting for Gemma response...');
      final response = await session.getResponse();
      print('✅ [ASK] Gemma raw response: $response');

      // Save context for next follow-up
      _lastQuestion = question;
      _lastResponse = response.length > 300
          ? response.substring(0, 300)
          : response;
      // Only update topic if NOT a follow-up
      if (!_isFollowUp(question)) {
        _currentTopic = question;
      }
      print('💾 [CONTEXT] Saved — topic: "$_currentTopic" | last Q: "$_lastQuestion"');

      if (language == 'Hindi') {
        print('🔄 [ASK] Translating to Hindi...');
        final translated = await _translateToHindi(response);
        print('✅ [ASK] Final Hindi response: $translated');
        yield translated;
      } else {
        print('✅ [ASK] Yielding English response');
        yield response;
      }
    } finally {
      await session.close();
      print('🔒 [ASK] Session closed');
    }
  }

  static Future<AIResponse> generateResponse(
    String query, {
    bool concise = true,
    String language = 'English',
  }) async {
    print('📝 [GENERATE] Query: $query | Language: $language');
    final subject = detectSubject(query);
    print('📝 [GENERATE] Detected subject: $subject');
    final buffer = StringBuffer();

    await for (final chunk in askStream(query, concise: concise, language: language)) {
      buffer.write(chunk);
    }

    final fullText = buffer.toString();
    print('📝 [GENERATE] Final response length: ${fullText.length}');
    return AIResponse(subject: subject, concise: fullText, detailed: fullText);
  }

  static void clearContext() {
    _lastQuestion = '';
    _lastResponse = '';
    _currentTopic = '';
    print('🧹 [CONTEXT] Conversation context cleared');
  }

  static void dispose() {
    _translator?.close();
    print('🔒 [DISPOSE] Translator closed');
  }
}
