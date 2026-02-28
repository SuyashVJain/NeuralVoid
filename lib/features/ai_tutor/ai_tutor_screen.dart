// lib/features/ai_tutor/ai_tutor_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:neural_learn/l10n/app_localizations.dart';
import 'package:neural_learn/models/student_model.dart';
import 'package:neural_learn/models/chat_message_model.dart';
import 'package:neural_learn/services/ai_router_service.dart';
import 'package:neural_learn/features/books/books_screen.dart';
import 'package:neural_learn/features/settings/settings_screen.dart';
import 'package:neural_learn/progress/controllers/progress_controller.dart';
import 'package:neural_learn/progress/screens/progress_dashboard_screen.dart';
import 'package:neural_learn/features/quiz/models/quiz_question.dart';
import 'package:neural_learn/features/quiz/screens/quiz_screen.dart';
import 'package:neural_learn/core/providers/locale_provider.dart';

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
  int? _streamingIndex;
  bool _isLoading = false;
  bool isConciseMode = true;
  String currentSubjectKey = 'general';

  static const _subjectIcons = {
    'general':       Icons.lightbulb_outline,
    'mathematics':   Icons.calculate_outlined,
    'science':       Icons.science_outlined,
    'socialScience': Icons.public_outlined,
  };

  String _localizedSubject(AppLocalizations l10n, String key) {
    switch (key) {
      case 'mathematics':   return l10n.mathematics;
      case 'science':       return l10n.science;
      case 'socialScience': return l10n.socialScience;
      default:              return l10n.general;
    }
  }

  Future<void> sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    _messageController.clear();

    setState(() {
      _isLoading = true;
      messages.add(ChatMessage(role: 'user', content: text));
      messages.add(ChatMessage(role: 'ai', content: ''));
      _streamingIndex = messages.length - 1;
    });

    _scrollToBottom();

    Provider.of<ProgressController>(context, listen: false).updateDoubt(
      subject: currentSubjectKey,
      chapter: 'General',
    );

    final buffer = StringBuffer();

final locale = Provider.of<LocaleProvider>(context, listen: false).locale.languageCode;
final language = locale == 'hi' ? 'Hindi' : 'English';

await for (final chunk in AIRouterService.askStream(text, concise: isConciseMode, language: language)) {      buffer.write(chunk);
      if (mounted) {
        setState(() {
          messages[_streamingIndex!] =
              ChatMessage(role: 'ai', content: buffer.toString());
        });
        _scrollToBottom();
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _streamingIndex = null;
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void startMockQuiz() {
    final questions = [
      QuizQuestion(
        question: 'If x² - 4 = 0, what is x?',
        options: ['2', '4', '6', '8'],
        correctIndex: 0,
        explanation: 'x² = 4 → x = ±2',
      ),
      QuizQuestion(
        question: 'Nature of roots if discriminant = 0?',
        options: ['Real and equal', 'Real and distinct', 'Imaginary', 'Undefined'],
        correctIndex: 0,
        explanation: 'If D = 0 → roots are real and equal.',
      ),
    ];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          subject: 'Maths',
          chapter: 'Quadratic Equations',
          questions: questions,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      resizeToAvoidBottomInset: true,
      drawer: _buildDrawer(context, l10n, primary),
      appBar: _buildAppBar(l10n, primary),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                const Spacer(),
                _ServerStatusDot(isLoading: _isLoading),
              ],
            ),
          ),
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
                      final isUser = message.role == 'user';
                      final isStreaming = index == _streamingIndex;
                      return _ChatBubble(
                        message: message,
                        isUser: isUser,
                        isStreaming: isStreaming,
                        primary: primary,
                      );
                    },
                  ),
          ),
          _InputBar(
            controller: _messageController,
            hint: l10n.askDoubt,
            primary: primary,
            isLoading: _isLoading,
            onSend: sendMessage,
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(AppLocalizations l10n, Color primary) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
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
            child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NeuralLearn',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: primary,
                      height: 1.1)),
              Text(
                _localizedSubject(AppLocalizations.of(context)!, currentSubjectKey),
                style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                    height: 1.1),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.bar_chart),
          tooltip: 'Progress Tracker',
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ProgressDashboardScreen())),
        ),
        IconButton(
          icon: const Icon(Icons.quiz),
          tooltip: 'Take Quiz',
          onPressed: startMockQuiz,
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: const Color(0xFFE2E8F0)),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AppLocalizations l10n, Color primary) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              color: primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.bolt_rounded,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 12),
                  const Text('NeuralLearn',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800)),
                  Text(widget.student.name,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _DrawerSectionLabel(label: l10n.aiTutor),
            ..._subjectIcons.keys
                .map((key) => _buildSubjectTile(context, l10n, key, primary)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Divider(),
            ),
            _DrawerNavTile(
              icon: Icons.menu_book_rounded,
              label: l10n.ncertBooks,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const BooksScreen()));
              },
            ),
            _DrawerNavTile(
              icon: Icons.settings_rounded,
              label: l10n.settings,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()));
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
        color: isSelected ? primary.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(_subjectIcons[key],
            color: isSelected ? primary : const Color(0xFF94A3B8), size: 20),
        title: Text(
          _localizedSubject(l10n, key),
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? primary : const Color(0xFF334155),
          ),
        ),
        trailing: isSelected ? Icon(Icons.circle, color: primary, size: 8) : null,
        onTap: () {
          setState(() => currentSubjectKey = key);
          Navigator.pop(context);
        },
      ),
    );
  }
}

// ── Supporting Widgets ──────────────────────────────────────

class _ServerStatusDot extends StatelessWidget {
  final bool isLoading;
  const _ServerStatusDot({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isLoading ? Colors.orange : Colors.green,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          isLoading ? 'Thinking...' : 'Ready',
          style: TextStyle(
            fontSize: 11,
            color: isLoading ? Colors.orange : Colors.green,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

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
        leading: Icon(icon, color: const Color(0xFF64748B), size: 20),
        title: Text(label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155))),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : const Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isUser;
  final bool isStreaming;
  final Color primary;

  const _ChatBubble({
    required this.message,
    required this.isUser,
    required this.isStreaming,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = message.content.isEmpty;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
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
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isEmpty && isStreaming
            ? _TypingIndicator(color: primary)
            : isUser
                ? Text(
                    message.content,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: Colors.white,
                    ),
                  )
                : MarkdownBody(
                    data: message.content,
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF1E293B),
                      ),
                      strong: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E3A8A),
                      ),
                      em: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF1E293B),
                      ),
                      listBullet: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1E293B),
                      ),
                      listIndent: 16,
                      blockquote: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF475569),
                        fontStyle: FontStyle.italic,
                      ),
                      code: TextStyle(
                        fontSize: 13,
                        backgroundColor: const Color(0xFFEFF6FF),
                        color: const Color(0xFF1E3A8A),
                        fontFamily: 'monospace',
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      h1: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                      h2: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                      h3: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  final Color color;
  const _TypingIndicator({required this.color});

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final value = ((_controller.value + delay) % 1.0);
            final opacity =
                (value < 0.5 ? value * 2 : (1 - value) * 2).clamp(0.3, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withValues(alpha: opacity),
              ),
            );
          }),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String subject;
  final String hint;
  final Color primary;

  const _EmptyState(
      {required this.subject, required this.hint, required this.primary});

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
                color: primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome_rounded, color: primary, size: 32),
            ),
            const SizedBox(height: 16),
            Text(subject,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: primary)),
            const SizedBox(height: 6),
            Text(hint,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF94A3B8)),
                textAlign: TextAlign.center),
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
  final bool isLoading;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.hint,
    required this.primary,
    required this.isLoading,
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
              enabled: !isLoading,
              onSubmitted: (_) => onSend(),
              style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle:
                    const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: isLoading ? null : onSend,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isLoading ? const Color(0xFFCBD5E1) : primary,
                shape: BoxShape.circle,
                boxShadow: isLoading
                    ? []
                    : [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send_rounded,
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