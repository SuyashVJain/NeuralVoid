// lib/models/chat_message_model.dart

class ChatMessage {
  final String role; // "user" or "ai"
  final String content;

  ChatMessage({
    required this.role,
    required this.content,
  });
}