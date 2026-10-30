import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../models/post.dart';
import '../../../repositories/auth_repository.dart';
import '../../../repositories/friend_repository.dart';
import '../../../viewmodels/feed_viewmodel.dart';
import '../friends/friends_view.dart';
import '../widgets/post_card.dart';
import '../widgets/post_composer.dart';
import 'widgets/opportunity_stories.dart';

/// Home feed: composer, Friends shortcut and posts (search lives in the app
/// bar's search icon → search page).
class FeedView extends StatelessWidget {
  const FeedView({required this.viewModel, super.key});

  final FeedViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        if (viewModel.loading) {
          return const SkeletonList(count: 4, itemHeight: 170);
        }
        if (!viewModel.loaded) {
          return ErrorRetry(onRetry: viewModel.retry);
        }

        final posts = viewModel.visiblePosts;

        return RefreshIndicator(
          onRefresh: viewModel.refresh,
          child: CenteredContent(
            maxWidth: 680,
            child: ListView(
              children: [
                // Composer -----------------------------------------------
                _ComposerButton(
                  onPost: (draft) async {
                    await viewModel.createPost(draft);
                    if (context.mounted) {
                      showAppSnackbar(context, 'Post published.');
                    }
                  },
                ),
                const SizedBox(height: 12),

                // Opportunity ads (stories-style strip) ------------------
                const OpportunityStories(),
                const SizedBox(height: 12),

                // Friends shortcut (replaces the old filter chips) -------
                const _FriendsShortcut(),
                const SizedBox(height: 12),

                // Posts ---------------------------------------------------
                if (posts.isEmpty)
                  EmptyState(
                    icon: viewModel.query.isNotEmpty ? Icons.search_off_rounded : Icons.forum_outlined,
                    title: viewModel.query.isNotEmpty ? 'No results found' : 'Nothing here yet',
                    message: viewModel.query.isNotEmpty
                        ? 'Try a different search term.'
                        : 'When members and your school post updates, they\'ll appear here.',
                  )
                else
                  for (final post in posts) ...[
                    PostCard(post: post),
                    const SizedBox(height: 12),
                  ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ComposerButton extends StatelessWidget {
  const _ComposerButton({required this.onPost});

  final Future<void> Function(PostDraft draft) onPost;

  @override
  Widget build(BuildContext context) {
    final me = AuthRepository.instance.currentUser;

    return SSCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      onTap: () async {
        final draft = await showPostComposer(context);
        if (draft != null) await onPost(draft);
      },
      child: Row(
        children: [
          AvatarCircle(name: me?.fullName ?? 'Member', radius: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Share a study tip, question or update…',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5)),
          ),
          const Icon(Icons.add_circle_rounded, color: AppColors.teal, size: 26),
        ],
      ),
    );
  }
}

/// Shortcut card opening the Friends page; shows a badge while friend
/// requests are pending.
class _FriendsShortcut extends StatelessWidget {
  const _FriendsShortcut();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: FriendRepository.instance,
      builder: (context, _) {
        final pending = FriendRepository.instance.pendingCount;

        return SSCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const FriendsView()),
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.people_alt_outlined, color: AppColors.primary, size: 24),
                  if (pending > 0)
                    Positioned(
                      top: -6,
                      right: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(color: AppColors.white, width: 1.5),
                        ),
                        child: Text(
                          '$pending',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Friends',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              ),
              if (pending > 0)
                Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Text(
                    'Requests pending',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 22),
            ],
          ),
        );
      },
    );
  }
}

