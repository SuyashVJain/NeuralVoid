// lib/features/ai_tutor/ai_tutor_screen.dart
import 'package:flutter/material.dart';
import '../../models/student_model.dart';
import '../../services/ai_router_service.dart';

class AITutorScreen extends StatefulWidget {
  final Student student;

  const AITutorScreen({super.key, required this.student});

  @override
  State<AITutorScreen> createState() => _AITutorScreenState();
}

class _AITutorScreenState extends State<AITutorScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> messages = [];

  bool isConciseMode = true;

  void sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final aiResponse = AIRouterService.generateResponse(text);

    setState(() {
      messages.add({"role": "user", "content": text});

      messages.add({
        "role": "ai",
        "content": isConciseMode
            ? aiResponse.concise
            : aiResponse.detailed,
      });
    });

    _messageController.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("NeuralLearn AI Tutor"),
      ),
      body: Column(
        children: [
          // ===== Toggle Section =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text("Concise"),
                  selected: isConciseMode,
                  onSelected: (_) {
                    setState(() {
                      isConciseMode = true;
                    });
                  },
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text("Detailed"),
                  selected: !isConciseMode,
                  onSelected: (_) {
                    setState(() {
                      isConciseMode = false;
                    });
                  },
                ),
              ],
            ),
          ),

          // ===== Chat Messages =====
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = message["role"] == "user";

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 300),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message["content"] ?? "",
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ===== Input Bar =====
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: "Ask your doubt...",
                      ),
                      onSubmitted: (_) => sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: sendMessage,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}