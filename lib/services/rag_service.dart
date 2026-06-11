import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

class RagService {
  static List<String>? _chunks;
  static List<List<double>>? _embeddings;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    print('📚 [RAG] Loading chunks and embeddings...');

    final chunksJson = await rootBundle.loadString('assets/rag/chunks.json');
    _chunks = (jsonDecode(chunksJson) as List)
        .map((e) => e.toString())
        .toList();

    final embeddingsJson = await rootBundle.loadString('assets/rag/embeddings.json');
    final raw = jsonDecode(embeddingsJson) as List;
    _embeddings = raw
        .map((e) => (e as List).map((v) => (v as num).toDouble()).toList())
        .toList();

    print('✅ [RAG] Loaded ${_chunks!.length} chunks, ${_embeddings!.length} embeddings');
    _initialized = true;
  }

  // Compute dot product similarity between two vectors
  static double _cosineSimilarity(List<double> a, List<double> b) {
    double dot = 0, normA = 0, normB = 0;
    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    if (normA == 0 || normB == 0) return 0;
    return dot / (sqrt(normA) * sqrt(normB));
  }

  // Simple TF-IDF query vector (bag of words approximation)
  static List<double> _queryToVector(String query) {
    if (_embeddings == null || _embeddings!.isEmpty) return [];
    final dim = _embeddings!.first.length;
    final vec = List<double>.filled(dim, 0.0);

    final queryWords = query.toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 2)
        .toList();

    // Find chunks that match query words and average their embeddings
    // as a proxy for the query embedding
    final scores = <int, double>{};
    for (int i = 0; i < _chunks!.length; i++) {
      final chunkLower = _chunks![i].toLowerCase();
      int matches = 0;
      for (final w in queryWords) {
        if (chunkLower.contains(w)) matches++;
      }
      if (matches > 0) scores[i] = matches.toDouble();
    }

    if (scores.isEmpty) return vec;

    // Average top 10 matching chunk embeddings as query vector
    final top = (scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)))
        .take(10)
        .map((e) => e.key)
        .toList();

    for (final idx in top) {
      final emb = _embeddings![idx];
      for (int d = 0; d < dim; d++) {
        vec[d] += emb[d];
      }
    }
    for (int d = 0; d < dim; d++) {
      vec[d] /= top.length;
    }
    return vec;
  }

  static List<String> retrieve(String query, {int topK = 3}) {
    if (_chunks == null || _embeddings == null || _chunks!.isEmpty) {
      print('⚠️ [RAG] Not initialized!');
      return [];
    }

    print('🔍 [RAG] Vector search for: "$query"');

    final queryVec = _queryToVector(query);
    if (queryVec.isEmpty || queryVec.every((v) => v == 0)) {
      print('⚠️ [RAG] Empty query vector, falling back to keyword search');
      return _keywordSearch(query, topK: topK);
    }

    // Score all chunks by cosine similarity
    final scores = <int, double>{};
    for (int i = 0; i < _embeddings!.length; i++) {
      final sim = _cosineSimilarity(queryVec, _embeddings![i]);
      if (sim > 0.3) scores[i] = sim;
    }

    print('🔍 [RAG] Chunks above threshold: ${scores.length}');

    if (scores.isEmpty) {
      print('⚠️ [RAG] No vector matches, falling back to keyword search');
      return _keywordSearch(query, topK: topK);
    }

    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topChunks = sorted.take(topK).map((e) => _chunks![e.key]).toList();

    for (int i = 0; i < topChunks.length; i++) {
      final preview = topChunks[i].substring(0, min(80, topChunks[i].length));
      print('🔍 [RAG] Top $i (sim: ${sorted[i].value.toStringAsFixed(3)}): $preview...');
    }

    return topChunks;
  }

  static List<String> _keywordSearch(String query, {int topK = 3}) {
    final queryWords = query.toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 2)
        .toSet();

    final scores = <int, double>{};
    for (int i = 0; i < _chunks!.length; i++) {
      final chunkWords = _chunks![i].toLowerCase()
          .split(RegExp(r'\s+'))
          .toSet();
      final overlap = queryWords.intersection(chunkWords).length;
      if (overlap > 0) {
        scores[i] = overlap / sqrt(chunkWords.length.toDouble());
      }
    }

    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(topK).map((e) => _chunks![e.key]).toList();
  }
}