import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/ui_kit.dart';
import '../../../../models/enums.dart';
import '../../../../models/post.dart';
import '../../../../repositories/auth_repository.dart';
import '../../../../repositories/feed_repository.dart';
import 'post_composer.dart';
import 'report_dialog.dart';

/// "⋯" post-actions menu (edit / delete for your own posts, report for
/// others'). Shared wherever [PostCard] is embedded.
class PostMenuButton extends StatelessWidget {
  const PostMenuButton({required this.post, super.key});

  final Post post;

  bool get _isMine =>
      post.authorId != null && post.authorId == AuthRepository.instance.currentUser?.id;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Post actions',
      icon: Icon(Icons.more_horiz_rounded, color: AppColors.textSecondary, size: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (_) => _menuItems(),
      onSelected: (value) => _onMenuAction(context, value),
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
        final draft = await showPostComposer(context, existing: post);
        if (draft != null && context.mounted) {
          await FeedRepository.instance.editPost(post.id, draft);
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
}

/// "Share post" dialog with a copy-link action.
void showPostShareDialog(BuildContext context) {
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
