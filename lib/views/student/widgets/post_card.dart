import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/ui_kit.dart';
import '../../../../models/enums.dart';
import '../../../../models/post.dart';
import '../../../../repositories/auth_repository.dart';
import '../../../../repositories/feed_repository.dart';
import 'comments_sheet.dart';
import 'post_composer.dart';
import 'report_dialog.dart';

/// Reusable post card used by the home feed and the student profile.
///
/// All actions go through [FeedRepository], so the card works identically
/// wherever it is embedded.
class PostCard extends StatelessWidget {
  const PostCard({required this.post, super.key});

  final Post post;

  bool get _isMine =>
      post.authorId != null && post.authorId == AuthRepository.instance.currentUser?.id;

  @override
  Widget build(BuildContext context) {
    final isAnnouncement = post.isAnnouncement;
    final accent = post.type == PostType.adminAnnouncement
        ? AppColors.teal
        : isAnnouncement
            ? AppColors.gold
            : AppColors.primary;

    return SSCard(
      border: isAnnouncement ? Border.all(color: accent.withValues(alpha: 0.45)) : null,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header -------------------------------------------------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AvatarCircle(
                name: post.authorName,
                radius: 20,
                icon: isAnnouncement ? Icons.campaign_rounded : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            post.authorName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                        ),
                        if (isAnnouncement) ...[
                          const SizedBox(width: 6),
                          Flexible(
                            child: StatusPill(text: postTypeLabel(post.type), color: accent),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      post.authorInstitution,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Text(timeAgo(post.timestamp),
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              PopupMenuButton<String>(
                tooltip: 'Post actions',
                icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textSecondary, size: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                itemBuilder: (_) => _menuItems(),
                onSelected: (value) => _onMenuAction(context, value),
              ),
            ],
          ),

          // Body ---------------------------------------------------------
          if (post.title != null) ...[
            const SizedBox(height: 10),
            Text(post.title!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ],
          const SizedBox(height: 8),
          Text(post.content, style: const TextStyle(fontSize: 14, height: 1.5)),
          if (post.hasImage) ...[
            const SizedBox(height: 10),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent.withValues(alpha: 0.25), AppColors.teal.withValues(alpha: 0.25)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_rounded, color: AppColors.textSecondary),
                  SizedBox(height: 6),
                  Text('Photo attachment',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],

          // Actions ------------------------------------------------------
          const SizedBox(height: 6),
          Row(
            children: [
              _ActionButton(
                icon: post.likedByMe ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                label: '${post.likeCount}',
                active: post.likedByMe,
                activeColor: AppColors.error,
                onTap: () => FeedRepository.instance.toggleLike(post.id),
              ),
              _ActionButton(
                icon: Icons.mode_comment_outlined,
                label: '${post.comments.length}',
                onTap: () => showCommentsSheet(context, post),
              ),
              _ActionButton(
                icon: Icons.share_outlined,
                label: 'Share',
                onTap: () => _showShareDialog(context),
              ),
              const Spacer(),
              if (_isMine)
                const StatusPill(text: 'Your post', color: AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  List<PopupMenuEntry<String>> _menuItems() {
    final items = <PopupMenuEntry<String>>[
      const PopupMenuItem(value: 'report', child: ListTile(
        leading: Icon(Icons.flag_outlined),
        title: Text('Report post'),
        contentPadding: EdgeInsets.zero,
      )),
    ];
    if (_isMine) {
      items.insertAll(0, const [
        PopupMenuItem(value: 'edit', child: ListTile(
          leading: Icon(Icons.edit_outlined),
          title: Text('Edit post'),
          contentPadding: EdgeInsets.zero,
        )),
        PopupMenuItem(value: 'delete', child: ListTile(
          leading: Icon(Icons.delete_outline, color: AppColors.error),
          title: Text('Delete post', style: TextStyle(color: AppColors.error)),
          contentPadding: EdgeInsets.zero,
        )),
      ]);
    }
    return items;
  }

  Future<void> _onMenuAction(BuildContext context, String value) async {
    switch (value) {
      case 'edit':
        final result = await showPostComposer(context, existing: post);
        if (result != null && context.mounted) {
          await FeedRepository.instance.editPost(post.id, result.$1);
        }
      case 'delete':
        final confirmed = await showConfirmDialog(
          context,
          title: 'Delete post?',
          message: 'This removes the post from your feed. This cannot be undone.',
          confirmLabel: 'Delete',
        );
        if (confirmed && context.mounted) FeedRepository.instance.deletePost(post.id);
      case 'report':
        if (!context.mounted) return;
        await showReportDialog(
          context,
          title: 'Report this post',
          onSubmit: (reason, notes) {
            FeedRepository.instance.markReported(post.id);
            AdminReportSink.instance.submit(
              target: ReportTarget.post,
              targetId: post.id,
              targetTitle: post.content.split('\n').first,
              reason: reason,
            );
            showAppSnackbar(context, 'Report submitted for review.');
          },
        );
    }
  }

  void _showShareDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Share post'),
        content: const Text(
          'Copy a link to this post or share it with your school community.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              showAppSnackbar(context, 'Link copied.');
            },
            child: const Text('Copy link'),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.activeColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final color = active ? (activeColor ?? AppColors.primary) : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12.5, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
