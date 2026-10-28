import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/ui_kit.dart';
import '../../../../models/conversation.dart';

/// Reusable conversation row used in the inbox tabs (conversations,
/// requests and groups) and the desktop split view.
class ConversationTile extends StatelessWidget {
  const ConversationTile({
    required this.conversation,
    required this.onTap,
    this.trailing,
    super.key,
  });

  final Conversation conversation;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = conversation;
    final hasUnread = c.unreadCount > 0;

    return SSCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          AvatarCircle(
            name: c.peerName,
            radius: 22,
            icon: c.isGroup ? Icons.groups_rounded : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(c.peerName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: hasUnread ? FontWeight.w800 : FontWeight.w700,
                            fontSize: 14,
                          )),
                    ),
                    if (c.blocked) ...[
                      const SizedBox(width: 6),
                      const StatusPill(text: 'Blocked', color: AppColors.error),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  c.preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: hasUnread ? AppColors.textPrimary : AppColors.textSecondary,
                    fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing ??
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(timeAgo(c.lastTimestamp),
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  if (hasUnread)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text('${c.unreadCount}',
                          style: const TextStyle(
                              fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)),
                    )
                  else
                    const SizedBox(height: 16),
                ],
              ),
        ],
      ),
    );
  }
}
