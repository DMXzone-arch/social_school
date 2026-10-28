import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/responsive.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../models/enums.dart';
import '../../../models/post.dart';
import '../../../repositories/admin_repository.dart';
import '../../../repositories/feed_repository.dart';
import 'admin_shell.dart';

/// Admin feed management: posts overview, announcements and removals.
class FeedManagementView extends StatefulWidget {
  const FeedManagementView({super.key});

  @override
  State<FeedManagementView> createState() => _FeedManagementViewState();
}

class _FeedManagementViewState extends State<FeedManagementView> {
  String _query = '';
  PostType? _type;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([FeedRepository.instance, AdminRepository.instance]),
      builder: (context, _) {
        final posts = FeedRepository.instance.posts.where((post) {
          final matchesType = _type == null || post.type == _type;
          final matchesQuery = _query.isEmpty ||
              post.content.toLowerCase().contains(_query.toLowerCase()) ||
              post.authorName.toLowerCase().contains(_query.toLowerCase());
          return matchesType && matchesQuery;
        }).toList();

        return CenteredContent(
          maxWidth: 1100,
          child: ListView(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Feed Management',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.teal),
                    onPressed: _showAnnouncementDialog,
                    icon: const Icon(Icons.campaign_rounded, size: 18),
                    label: const Text('Publish announcement'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Announcements published here appear at the top of the student feed (demo).',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              AppSearchField(hint: 'Search posts…', onChanged: (v) => setState(() => _query = v)),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    appFilterChip('All', selected: _type == null,
                        onTap: () => setState(() => _type = null)),
                    for (final type in PostType.values) ...[
                      const SizedBox(width: 8),
                      appFilterChip(postTypeLabel(type),
                          selected: _type == type, onTap: () => setState(() => _type = type)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (posts.isEmpty)
                const EmptyState(
                  icon: Icons.forum_outlined,
                  title: 'No posts match',
                  message: 'Try a different search or filter.',
                )
              else
                for (final post in posts) ...[
                  _PostAdminCard(post: post),
                  const SizedBox(height: 10),
                ],
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  void _showAnnouncementDialog() {
    final title = TextEditingController();
    final body = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Publish announcement'),
        content: SizedBox(
          width: 460,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: title,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Announcement title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: body,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Message to students',
                  hintText: 'e.g. Mock exams begin Monday…',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  DemoBadge(label: 'DEMO'),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Simulated: the announcement is added to the shared demo '
                      'feed shown by the student app.',
                      style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.teal),
            onPressed: () async {
              if (title.text.trim().isEmpty || body.text.trim().isEmpty) {
                showAppSnackbar(context, 'Title and message are required.', error: true);
                return;
              }
              Navigator.pop(dialogContext);
              await AdminRepository.instance.publishAnnouncement(title.text, body.text);
              if (mounted) {
                showAppSnackbar(context, 'Announcement published — visible in the student feed.');
              }
            },
            child: const Text('Publish'),
          ),
        ],
      ),
    );
  }
}

class _PostAdminCard extends StatelessWidget {
  const _PostAdminCard({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final accent = switch (post.type) {
      PostType.studentPost => AppColors.primary,
      PostType.schoolAnnouncement => AppColors.gold,
      PostType.adminAnnouncement => AppColors.teal,
    };

    return SSCard(
      padding: const EdgeInsets.all(14),
      color: post.removedByAdmin ? AppColors.background : AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarCircle(name: post.authorName, radius: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.authorName,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                    Text(
                      '${post.authorInstitution} · ${timeAgo(post.timestamp)}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              StatusPill(text: postTypeLabel(post.type), color: accent),
              if (post.removedByAdmin) ...[
                const SizedBox(width: 6),
                const StatusPill(text: 'Removed', color: AppColors.error),
              ],
            ],
          ),
          const SizedBox(height: 10),
          if (post.title != null)
            Text(post.title!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 4),
          Text(post.content,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, height: 1.45)),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('♥ ${post.likeCount} · 💬 ${post.comments.length}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const Spacer(),
              if (post.removedByAdmin)
                TextButton.icon(
                  onPressed: () {
                    AdminRepository.instance.restorePost(post.id);
                    showAppSnackbar(context, 'Post restored to the feed.');
                  },
                  icon: const Icon(Icons.restore_rounded, size: 16, color: AppColors.success),
                  label: const Text('Restore', style: TextStyle(color: AppColors.success)),
                )
              else
                TextButton.icon(
                  onPressed: () async {
                    final confirmed = await showAdminConfirm(
                      context,
                      title: 'Remove this post?',
                      message: 'The post will be hidden from the student feed (demo).',
                      confirmLabel: 'Remove post',
                    );
                    if (confirmed && context.mounted) {
                      AdminRepository.instance.removePost(post.id);
                      showAppSnackbar(context, 'Post removed from the student feed.');
                    }
                  },
                  icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
                  label: const Text('Remove', style: TextStyle(color: AppColors.error)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
