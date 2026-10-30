import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/states.dart';
import '../../../repositories/chat_repository.dart';
import 'widgets/conversation_bar.dart';
import 'widgets/message_list.dart';

/// Direct/group chat: bubbles, timestamps, delivery indicators and input.
/// Blocked or unaccepted conversations show the relevant demo state instead
/// of the composer.
class ConversationView extends StatefulWidget {
  const ConversationView({required this.conversationId, this.embedded = false, super.key});

  final String conversationId;

  /// True when embedded in the desktop split view (no own app bar push).
  final bool embedded;

  @override
  State<ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends State<ConversationView> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    ChatRepository.instance.sendMessage(widget.conversationId, text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ChatRepository.instance,
      builder: (context, _) {
        final conversation = ChatRepository.instance.byId(widget.conversationId);
        if (conversation == null) {
          return const Scaffold(body: EmptyState(icon: Icons.chat_bubble_outline, title: 'Conversation closed'));
        }

        final body = Column(
          children: [
            Expanded(child: MessageList(conversation: conversation)),
            if (conversation.blocked)
              const _StateBanner(
                icon: Icons.block_rounded,
                text: 'You blocked this account. Unblock from Settings → Blocked users.',
                color: AppColors.error,
              )
            else if (!conversation.canMessage)
              const _StateBanner(
                icon: Icons.hourglass_top_rounded,
                text: 'Messaging unlocks once the other person accepts the request.',
                color: Color(0xFFB45309),
              )
            else
              _Composer(controller: _controller, onSend: _send, isGroup: conversation.isGroup),
          ],
        );

        if (widget.embedded) {
          return Column(
            children: [
              ConversationBar(conversation: conversation, withBack: false),
              Expanded(child: body),
            ],
          );
        }

        return Scaffold(
          appBar: null,
          body: Column(
            children: [
              SafeArea(bottom: false, child: ConversationBar(conversation: conversation, withBack: true)),
              Expanded(child: body),
            ],
          ),
        );
      },
    );
  }
}

/// Full-width banner shown instead of the composer when the conversation is
/// blocked or still waiting for the other student to accept the request.
class _StateBanner extends StatelessWidget {
  const _StateBanner({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: color.withValues(alpha: 0.08),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 12.5, color: color, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

/// Message input row pinned to the bottom of the conversation.
class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSend, required this.isGroup});

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isGroup;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: isGroup ? 'Message the group…' : 'Type a message…',
                isDense: true,
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            tooltip: 'Send',
            onPressed: onSend,
            icon: const Icon(Icons.send_rounded, size: 20),
          ),
        ],
      ),
    );
  }
}
