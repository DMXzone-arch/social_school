import 'package:flutter/material.dart';

import '../../../core/widgets/responsive.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../models/post.dart';
import '../../../viewmodels/feed_viewmodel.dart';
import '../widgets/post_card.dart';

/// Dedicated feed search screen, opened from the home app bar's search icon.
///
/// The field is focused immediately and filters live using the same keyword
/// rules as the feed (content / author / title). All query state is local —
/// the home feed behind is never mutated, so popping the route needs no
/// cleanup.
class FeedSearchView extends StatefulWidget {
  const FeedSearchView({required this.viewModel, super.key});

  final FeedViewModel viewModel;

  @override
  State<FeedSearchView> createState() => _FeedSearchViewState();
}

class _FeedSearchViewState extends State<FeedSearchView> {
  String _query = '';

  List<Post> _results(List<Post> base) {
    final normalized = _query.trim().toLowerCase();
    if (normalized.isEmpty) return const [];
    return [
      for (final post in base)
        if (post.content.toLowerCase().contains(normalized) ||
            post.authorName.toLowerCase().contains(normalized) ||
            (post.title?.toLowerCase().contains(normalized) ?? false))
          post,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          if (viewModel.loading) {
            return const SkeletonList(count: 4, itemHeight: 170);
          }

          final results = _results(viewModel.visiblePosts);

          return CenteredContent(
            maxWidth: 680,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: AppSearchField(
                    autofocus: true,
                    hint: 'Search the feed…',
                    onChanged: (value) => setState(() => _query = value),
                  ),
                ),
                Expanded(
                  child: _query.trim().isEmpty
                      ? const EmptyState(
                          icon: Icons.search_rounded,
                          title: 'Search the feed',
                          message: 'Find posts by topic, name or keyword.',
                        )
                      : results.isEmpty
                          ? const EmptyState(
                              icon: Icons.search_off_rounded,
                              title: 'No results found',
                              message: 'Try a different search term.',
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                              itemCount: results.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 12),
                              itemBuilder: (context, index) => PostCard(post: results[index]),
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
