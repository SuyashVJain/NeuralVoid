import 'dart:async';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import '../models/ai_response_model.dart';

class AIRouterService {
  static InferenceModel? _model;
  static bool _initialized = false;
  static OnDeviceTranslator? _translator;
  static bool _translatorReady = false;

  static String detectSubject(String query) {
    final q = query.toLowerCase();
    if (q.contains('math') || q.contains('equation') || q.contains('number')) {
      return 'Mathematics';
    }
    if (q.contains('reaction') || q.contains('science') || q.contains('chemical')) {
      return 'Science';
    }
    if (q.contains('history') || q.contains('geography') || q.contains('civics')) {
      return 'Social Science';
    }
    return 'General';
  }

  static Future<void> initialize() async {
    if (_initialized) return;
    print('🔧 [INIT] Starting Gemma model initialization...');

    await FlutterGemma.installModel(
      modelType: ModelType.gemmaIt,
    ).fromAsset('assets/model/gemma3-1B-it-int4.task').install();
    print('✅ [INIT] Gemma model installed');

    _model = await FlutterGemma.getActiveModel(
      maxTokens: 600,
      preferredBackend: PreferredBackend.gpu,
    );
    print('✅ [INIT] Gemma model loaded into memory');

    _initialized = true;
    print('✅ [INIT] Initialization complete');
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

      // Split by lines to avoid MLKit character limit
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
    print('💬 [ASK] Question: $question');
    print('💬 [ASK] Language: $language | Concise: $concise');

    await initialize();

    final modePrefix = concise
        ? 'You are an expert tutor. Answer this question in exactly 3 clear bullet points. '
          'Each bullet point should be a complete sentence. Be concise and accurate.\n\n'
        : 'You are an expert tutor. Give a detailed explanation with examples, '
          'common mistakes to avoid, and exam tips.\n\n';

    print('💬 [ASK] Sending prompt to Gemma...');
    final session = await _model!.createSession();

    try {
      await session.addQueryChunk(
        Message.text(text: '$modePrefix$question', isUser: true),
      );
      print('💬 [ASK] Waiting for Gemma response...');
      final response = await session.getResponse();
      print('✅ [ASK] Gemma raw response: $response');

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

  static void dispose() {
    _translator?.close();
    print('🔒 [DISPOSE] Translator closed');
  }
}