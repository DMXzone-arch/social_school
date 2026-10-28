import 'package:flutter/material.dart';

import '../../../core/widgets/responsive.dart';
import '../../../core/widgets/states.dart';
import '../../../repositories/auth_repository.dart';
import '../../../repositories/feed_repository.dart';
import '../widgets/post_card.dart';

/// All posts authored by the signed-in student.
///
/// Reached from the profile page's "My posts" action row; the profile itself
/// no longer inlines the list.
class MyPostsView extends StatelessWidget {
  const MyPostsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My posts')),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          AuthRepository.instance,
          FeedRepository.instance,
        ]),
        builder: (context, _) {
          final me = AuthRepository.instance.currentUser;
          if (me == null) {
            return const EmptyState(
              icon: Icons.person_off_outlined,
              title: 'Not signed in',
            );
          }
          final myPosts = FeedRepository.instance.posts
              .where((p) => p.authorId == me.id && !p.removedByAdmin)
              .toList();

          if (myPosts.isEmpty) {
            return const EmptyState(
              icon: Icons.forum_outlined,
              title: 'No posts yet',
              message: 'Posts you create from the home feed appear here.',
            );
          }

          return CenteredContent(
            maxWidth: 680,
            child: ListView.separated(
              itemCount: myPosts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => PostCard(post: myPosts[index]),
            ),
          );
        },
      ),
    );
  }
}
