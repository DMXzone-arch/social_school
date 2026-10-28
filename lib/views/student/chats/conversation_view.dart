import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../models/conversation.dart';
import '../../../repositories/chat_repository.dart';
import '../widgets/report_dialog.dart';

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
            Expanded(child: _MessageList(conversation: conversation)),
            if (conversation.blocked)
              const _StateBanner(
                icon: Icons.block_rounded,
                text: 'You blocked this account. Unblock from Settings → Blocked users.',
                color: AppColors.error,
              )
            else if (!conversation.canMessage)
              const _StateBanner(
                icon: Icons.hourglass_top_rounded,
                text: 'Messaging unlocks once the other student accepts the request.',
                color: Color(0xFFB45309),
              )
            else
              _Composer(controller: _controller, onSend: _send, isGroup: conversation.isGroup),
          ],
        );

        if (widget.embedded) {
          return Column(
            children: [
              _ConversationBar(conversation: conversation, withBack: false),
              Expanded(child: body),
            ],
          );
        }

        return Scaffold(
          appBar: null,
          body: Column(
            children: [
              SafeArea(bottom: false, child: _ConversationBar(conversation: conversation, withBack: true)),
              Expanded(child: body),
            ],
          ),
        );
      },
    );
  }
}

class _ConversationBar extends StatelessWidget {
  const _ConversationBar({required this.conversation, required this.withBack});

  final Conversation conversation;
  final bool withBack;

  @override
  Widget build(BuildContext context) {
    final c = conversation;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (withBack)
            IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          AvatarCircle(name: c.peerName, radius: 18, icon: c.isGroup ? Icons.groups_rounded : null),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.peerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                Text(
                  c.isGroup
                      ? c.peerSubtitle
                      : '${c.peerInstitution}${c.peerSubtitle.isEmpty ? '' : ' · ${c.peerSubtitle}'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Conversation info',
            onPressed: () => _showInfoDialog(context),
            icon: const Icon(Icons.info_outline_rounded),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    final c = conversation;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Conversation info'),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoRow(icon: Icons.person_outline_rounded, label: 'Name', value: c.peerName),
              InfoRow(icon: Icons.school_outlined, label: 'Institution', value: c.peerInstitution),
              InfoRow(icon: Icons.lock_outline_rounded, label: 'Messaging policy',
                  value: c.isGroup ? 'Group conversation (joined)' : 'Mutual approval required'),
              const Divider(height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.flag_outlined, color: AppColors.error),
                title: const Text('Report account', style: TextStyle(color: AppColors.error)),
                subtitle: const Text('Reviewed by a moderator.', style: TextStyle(fontSize: 11.5)),
                onTap: () {
                  Navigator.pop(dialogContext);
                  showReportDialog(
                    context,
                    title: 'Report ${c.peerName}',
                    onSubmit: (reason, notes) {
                      ChatRepository.instance.report(c.id, reason);
                      showAppSnackbar(context, 'Account reported.');
                    },
                  );
                },
              ),
              if (!c.isGroup)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(c.blocked ? Icons.block_rounded : Icons.block_outlined,
                      color: AppColors.textSecondary),
                  title: Text(c.blocked ? 'Unblock account' : 'Block account'),
                  subtitle: const Text('This action is logged.', style: TextStyle(fontSize: 11.5)),
                  onTap: () {
                    Navigator.pop(dialogContext);
                    c.blocked
                        ? ChatRepository.instance.unblock(c.id)
                        : ChatRepository.instance.block(c.id);
                  },
                ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close')),
        ],
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({required this.conversation});

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
        return _Bubble(message: message, showSender: conversation.isGroup);
      },
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.showSender});

  final Message message;
  final bool showSender;

  @override
  Widget build(BuildContext context) {
    final mine = message.fromMe;
    final bg = mine ? AppColors.primary : AppColors.white;

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

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSend, required this.isGroup});

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isGroup;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      decoration: const BoxDecoration(
        color: AppColors.white,
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
                  borderSide: const BorderSide(color: AppColors.border),
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
