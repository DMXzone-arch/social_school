import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/ui_kit.dart';
import '../../../../models/conversation.dart';
import '../../../../repositories/chat_repository.dart';
import '../../widgets/report_dialog.dart';

/// Conversation header shown above the message list: peer avatar, name and
/// subtitle, an optional back button (pushed routes) and an info button that
/// opens report/block actions for the conversation peer.
class ConversationBar extends StatelessWidget {
  const ConversationBar({required this.conversation, required this.withBack, super.key});

  final Conversation conversation;

  /// True when the bar should render a back button that pops the route.
  final bool withBack;

  @override
  Widget build(BuildContext context) {
    final c = conversation;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
                  style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
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
