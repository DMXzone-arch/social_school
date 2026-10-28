import 'package:flutter/material.dart';

import '../../../core/widgets/responsive.dart';
import '../../../core/widgets/states.dart';
import '../../../repositories/library_repository.dart';
import '../library/resource_detail_view.dart';
import '../library/widgets/resource_card.dart';

/// Library items the signed-in student bookmarked.
///
/// Reached from the profile page's "Saved resources" action row; the profile
/// itself no longer inlines the list.
class SavedResourcesView extends StatelessWidget {
  const SavedResourcesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved resources')),
      body: ListenableBuilder(
        listenable: LibraryRepository.instance,
        builder: (context, _) {
          final saved = LibraryRepository.instance.bookmarks;
          if (saved.isEmpty) {
            return const EmptyState(
              icon: Icons.bookmark_border_rounded,
              title: 'No saved resources',
              message: 'Bookmark library items to find them quickly later.',
            );
          }

          return CenteredContent(
            maxWidth: 680,
            child: ListView.separated(
              itemCount: saved.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final resource = saved[index];
                return ResourceCard(
                  resource: resource,
                  layout: ResourceLayout.list,
                  onOpen: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ResourceDetailView(resourceId: resource.id),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
