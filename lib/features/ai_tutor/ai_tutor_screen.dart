// lib/features/ai_tutor/ai_tutor_screen.dart
import 'package:flutter/material.dart';
import 'package:neural_learn/l10n/app_localizations.dart';
import 'package:neural_learn/models/student_model.dart';
import 'package:neural_learn/services/ai_router_service.dart';
import 'package:neural_learn/models/chat_message_model.dart';
import 'package:neural_learn/features/books/books_screen.dart';
import 'package:neural_learn/features/settings/settings_screen.dart';

class AITutorScreen extends StatefulWidget {
  final Student student;
  const AITutorScreen({super.key, required this.student});

  @override
  State<AITutorScreen> createState() => _AITutorScreenState();
}

class _AITutorScreenState extends State<AITutorScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> messages = [];
  bool isConciseMode = true;
  String currentSubjectKey = "general";

  static const _subjectIcons = {
    "general":       Icons.lightbulb_outline,
    "mathematics":   Icons.calculate_outlined,
    "science":       Icons.science_outlined,
    "socialScience": Icons.public_outlined,
  };

  String _localizedSubject(AppLocalizations l10n, String key) {
    switch (key) {
      case "mathematics":   return l10n.mathematics;
      case "science":       return l10n.science;
      case "socialScience": return l10n.socialScience;
      default:              return l10n.general;
    }
  }

  void sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final recentMessages = messages
        .takeLast(5)
        .map((m) => "${m.role}: ${m.content}")
        .join("\n");

    final aiResponse = AIRouterService.generateResponse(
      "$currentSubjectKey\nContext:\n$recentMessages\nUser: $text",
    );

    setState(() {
      messages.add(ChatMessage(role: "user", content: text));
      messages.add(ChatMessage(
        role: "ai",
        content: isConciseMode ? aiResponse.concise : aiResponse.detailed,
      ));
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
    final l10n = AppLocalizations.of(context)!;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      resizeToAvoidBottomInset: true,

      // ===================== DRAWER =====================
      drawer: _buildDrawer(context, l10n, primary),

      // ===================== APP BAR =====================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bolt_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "NeuralLearn",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: primary,
                    height: 1.1,
                  ),
                ),
                Text(
                  _localizedSubject(l10n, currentSubjectKey),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
      ),

      // ===================== BODY =====================
      body: Column(
        children: [
          // ── Mode Toggle ──
          Container(
            color: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _ModeChip(
                  label: l10n.concise,
                  icon: Icons.compress_rounded,
                  selected: isConciseMode,
                  onTap: () => setState(() => isConciseMode = true),
                  primary: primary,
                ),
                const SizedBox(width: 8),
                _ModeChip(
                  label: l10n.detailed,
                  icon: Icons.expand_rounded,
                  selected: !isConciseMode,
                  onTap: () => setState(() => isConciseMode = false),
                  primary: primary,
                ),
              ],
            ),
          ),

          // ── Chat Messages ──
          Expanded(
            child: messages.isEmpty
                ? _EmptyState(
                    subject: _localizedSubject(l10n, currentSubjectKey),
                    hint: l10n.askDoubt,
                    primary: primary,
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isUser = message.role == "user";
                      return _ChatBubble(
                          message: message,
                          isUser: isUser,
                          primary: primary);
                    },
                  ),
          ),

          // ── Input Bar ──
          _InputBar(
            controller: _messageController,
            hint: l10n.askDoubt,
            primary: primary,
            onSend: sendMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(
      BuildContext context, AppLocalizations l10n, Color primary) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: BoxDecoration(
                color: primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.bolt_rounded,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "NeuralLearn",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    widget.student.name,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // AI Tutor section label
            _DrawerSectionLabel(label: l10n.aiTutor),

            // Subject tiles
            ..._subjectIcons.keys.map((key) =>
                _buildSubjectTile(context, l10n, key, primary)),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Divider(),
            ),

            // Books
            _DrawerNavTile(
              icon: Icons.menu_book_rounded,
              label: l10n.ncertBooks,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const BooksScreen()));
              },
            ),

            // Settings
            _DrawerNavTile(
              icon: Icons.settings_rounded,
              label: l10n.settings,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SettingsScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectTile(BuildContext context, AppLocalizations l10n,
      String key, Color primary) {
    final isSelected = currentSubjectKey == key;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? primary.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          _subjectIcons[key],
          color: isSelected ? primary : const Color(0xFF94A3B8),
          size: 20,
        ),
        title: Text(
          _localizedSubject(l10n, key),
          style: TextStyle(
            fontSize: 14,
            fontWeight:
                isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? primary : const Color(0xFF334155),
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.circle, color: primary, size: 8)
            : null,
        onTap: () {
          setState(() => currentSubjectKey = key);
          Navigator.pop(context);
        },
      ),
    );
  }
}

// ── Supporting Widgets ──────────────────────────────────────

class _DrawerSectionLabel extends StatelessWidget {
  final String label;
  const _DrawerSectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF94A3B8),
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _DrawerNavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DrawerNavTile(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: ListTile(
        dense: true,
        leading:
            Icon(icon, color: const Color(0xFF64748B), size: 20),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color primary;

  const _ModeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? primary : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: selected ? Colors.white : const Color(0xFF94A3B8)),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color:
                    selected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isUser;
  final Color primary;

  const _ChatBubble(
      {required this.message,
      required this.isUser,
      required this.primary});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message.content,
          style: TextStyle(
            fontSize: 14,
            height: 1.45,
            color: isUser ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String subject;
  final String hint;
  final Color primary;

  const _EmptyState(
      {required this.subject,
      required this.hint,
      required this.primary});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome_rounded,
                  color: primary, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              subject,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hint,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF94A3B8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Color primary;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.hint,
    required this.primary,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: (_) => onSend(),
              style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle:
                    const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: primary, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

extension TakeLastExtension<E> on List<E> {
  List<E> takeLast(int n) {
    if (length <= n) return this;
    return sublist(length - n);
  }
}