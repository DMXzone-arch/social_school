import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../models/enums.dart';
import '../../../repositories/community_repository.dart';
import 'community_detail_view.dart';
import 'widgets/community_card.dart';

/// Browse and join student communities.
class CommunitiesView extends StatefulWidget {
  const CommunitiesView({super.key});

  @override
  State<CommunitiesView> createState() => _CommunitiesViewState();
}

class _CommunitiesViewState extends State<CommunitiesView> {
  EducationLevel? _level;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Communities')),
      body: ListenableBuilder(
        listenable: CommunityRepository.instance,
        builder: (context, _) {
          final communities = _level == null
              ? CommunityRepository.instance.communities
              : CommunityRepository.instance.byLevel(_level);

          return CenteredContent(
            maxWidth: 980,
            child: ListView(
              children: [
                const Text(
                  'Communities bring students together around a subject or cause. '
                  'Joining unlocks the community feed and group chat.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    appFilterChip('All', selected: _level == null, onTap: () => setState(() => _level = null)),
                    for (final level in EducationLevel.values)
                      appFilterChip(
                        educationLevelLabel(level),
                        selected: _level == level,
                        onTap: () => setState(() => _level = level),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (communities.isEmpty)
                  const EmptyState(
                    icon: Icons.groups_outlined,
                    title: 'No communities yet',
                    message: 'Try a different education level filter.',
                  )
                else
                  ResponsiveBuilder(
                    builder: (context, type) {
                      final columns = switch (type) {
                        ScreenType.mobile => 1,
                        ScreenType.tablet => 2,
                        ScreenType.desktop => 2,
                      };
                      // Mobile cards are full-width and stack title, description
                      // and the join row, so they need a taller cell.
                      final aspectRatio = switch (type) {
                        ScreenType.mobile => 1.55,
                        ScreenType.tablet => 1.9,
                        ScreenType.desktop => 2.1,
                      };
                      return GridView.count(
                        crossAxisCount: columns,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: aspectRatio,
                        children: [
                          for (final community in communities)
                            CommunityCard(
                              community: community,
                              onOpen: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CommunityDetailView(communityId: community.id),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
