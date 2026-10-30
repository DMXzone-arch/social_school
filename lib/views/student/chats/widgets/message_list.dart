import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/states.dart';
import '../../../../models/conversation.dart';

/// Reverse-chronological list of chat messages. Renders an empty state when
/// the conversation has no messages yet.
class MessageList extends StatelessWidget {
  const MessageList({required this.conversation, super.key});

  final Conversation conversation;

  @override
  Widget build(BuildContext context) {
    final messages = conversation.messages;

    if (messages.isEmpty) {
      return const EmptyState(
        icon: Icons.waving_hand_rounded,
        title: 'No messages yet',
        message: 'Say hello! Start a conversation.',
      );
    }

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[messages.length - 1 - index];
        return MessageBubble(message: message, showSender: conversation.isGroup);
      },
    );
  }
}

/// Single chat bubble with timestamp and, for own messages, the delivery
/// indicator. Group conversations can opt into showing the sender column via
/// [showSender].
class MessageBubble extends StatelessWidget {
  const MessageBubble({required this.message, required this.showSender, super.key});

  final Message message;
  final bool showSender;

  @override
  Widget build(BuildContext context) {
    final mine = message.fromMe;
    final bg = mine ? AppColors.primary : AppColors.surface;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.72),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(mine ? 16 : 4),
            bottomRight: Radius.circular(mine ? 4 : 16),
          ),
          border: mine ? null : Border.all(color: AppColors.border),
          boxShadow: const [BoxShadow(color: Color(0x081F2937), blurRadius: 6, offset: Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.text,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: mine ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: mine ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
                if (mine) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.status == MessageStatus.read
                        ? Icons.done_all_rounded
                        : Icons.check_rounded,
                    size: 13,
                    color: message.status == MessageStatus.read
                        ? const Color(0xFF7FD1FF)
                        : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
