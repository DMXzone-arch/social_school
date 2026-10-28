import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../models/enums.dart';
import '../../../repositories/auth_repository.dart';
import '../../../viewmodels/feed_viewmodel.dart';
import '../widgets/post_card.dart';
import '../widgets/post_composer.dart';

/// Student home feed: welcome message, composer, filters and posts.
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
        final me = AuthRepository.instance.currentUser;

        return RefreshIndicator(
          onRefresh: viewModel.refresh,
          child: CenteredContent(
            maxWidth: 680,
            child: ListView(
              children: [
                // Welcome card ------------------------------------------
                SSCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      AvatarCircle(name: me?.fullName ?? 'Student', radius: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back, ${me?.fullName.split(' ').first ?? 'Student'}! 👋',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              AppConstants.tagline,
                              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Search -------------------------------------------------
                AppSearchField(
                  hint: 'Search the feed…',
                  onChanged: viewModel.setQuery,
                ),
                const SizedBox(height: 12),

                // Composer -----------------------------------------------
                _ComposerButton(
                  onPost: (text, withImage) async {
                    await viewModel.createPost(text, withImage: withImage);
                    if (context.mounted) {
                      showAppSnackbar(context, 'Post published.');
                    }
                  },
                ),
                const SizedBox(height: 12),

                // Filters -------------------------------------------------
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      appFilterChip('For You', selected: viewModel.filter == FeedFilter.forYou,
                          onTap: () => viewModel.setFilter(FeedFilter.forYou), icon: Icons.explore_outlined),
                      const SizedBox(width: 8),
                      appFilterChip('My Institution',
                          selected: viewModel.filter == FeedFilter.myInstitution,
                          onTap: () => viewModel.setFilter(FeedFilter.myInstitution),
                          icon: Icons.school_outlined),
                      const SizedBox(width: 8),
                      appFilterChip('Following', selected: viewModel.filter == FeedFilter.following,
                          onTap: () => viewModel.setFilter(FeedFilter.following), icon: Icons.people_outline),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Posts ---------------------------------------------------
                if (posts.isEmpty)
                  EmptyState(
                    icon: viewModel.query.isNotEmpty ? Icons.search_off_rounded : Icons.forum_outlined,
                    title: viewModel.query.isNotEmpty ? 'No results found' : 'Nothing here yet',
                    message: viewModel.query.isNotEmpty
                        ? 'Try a different search term or clear the filters.'
                        : 'When students and your school post updates, they\'ll appear here.',
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

  final Future<void> Function(String text, bool withImage) onPost;

  @override
  Widget build(BuildContext context) {
    final me = AuthRepository.instance.currentUser;

    return SSCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      onTap: () async {
        final result = await showPostComposer(context);
        if (result != null) await onPost(result.$1, result.$2);
      },
      child: Row(
        children: [
          AvatarCircle(name: me?.fullName ?? 'Student', radius: 18),
          const SizedBox(width: 10),
          const Expanded(
            child: Text('Share a study tip, question or update…',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5)),
          ),
          const Icon(Icons.add_circle_rounded, color: AppColors.teal, size: 26),
        ],
      ),
    );
  }
}

