import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/responsive.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../models/enums.dart';
import '../../../models/notification_item.dart';
import '../../../repositories/notification_repository.dart';

/// Simulated notifications inbox.
class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: NotificationRepository.instance.markAllRead,
            child: const Text('Mark all read', style: TextStyle(fontSize: 12.5)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListenableBuilder(
        listenable: NotificationRepository.instance,
        builder: (context, _) {
          final items = NotificationRepository.instance.items;
          if (items.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'No notifications',
              message: 'Requests, comments and announcements will show up here.',
            );
          }

          return CenteredContent(
            maxWidth: 680,
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                return _NotificationTile(item: item);
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});

  final AppNotification item;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (item.type) {
      AppNotificationType.request => (Icons.alternate_email_rounded, AppColors.primary),
      AppNotificationType.accepted => (Icons.check_circle_rounded, AppColors.success),
      AppNotificationType.comment => (Icons.mode_comment_outlined, AppColors.teal),
      AppNotificationType.reaction => (Icons.favorite_outline_rounded, AppColors.error),
      AppNotificationType.adminAnnouncement => (Icons.campaign_rounded, AppColors.gold),
      AppNotificationType.scholarship => (Icons.school_rounded, AppColors.primary),
    };

    return SSCard(
      color: item.read ? AppColors.white : AppColors.primary.withValues(alpha: 0.04),
      padding: const EdgeInsets.all(14),
      onTap: () => NotificationRepository.instance.markRead(item.id),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(item.title,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: item.read ? FontWeight.w600 : FontWeight.w800)),
                    ),
                    if (!item.read)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: AppColors.primary, shape: BoxShape.circle),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(item.body,
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4)),
                const SizedBox(height: 4),
                Text(timeAgo(item.timestamp),
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
