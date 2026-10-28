import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../models/enums.dart';
import '../../../viewmodels/opportunity_viewmodel.dart';
import 'opportunity_detail_view.dart';
import 'widgets/opportunity_card.dart';

/// Browse scholarships, internships, competitions and more.
class OpportunitiesView extends StatelessWidget {
  const OpportunitiesView({required this.viewModel, super.key});

  final OpportunityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final results = viewModel.results;

        return CenteredContent(
          maxWidth: 980,
          child: ListView(
            children: [
              const Row(
                children: [
                  Expanded(
                    child: Text('Opportunities',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  ),
                  DemoBadge(),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Scholarships, internships, competitions and training '
                'programs updated weekly.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              AppSearchField(
                hint: 'Search scholarships, internships, training…',
                onChanged: viewModel.setQuery,
              ),
              const SizedBox(height: 12),

              // Category filter ------------------------------------------
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final category in OpportunityCategory.values) ...[
                      appFilterChip(
                        opportunityCategoryLabel(category),
                        selected: viewModel.category == category,
                        onTap: () => viewModel.setCategory(category),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Secondary filters ----------------------------------------
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (final level in EducationLevel.values)
                    appFilterChip(educationLevelLabel(level),
                        selected: viewModel.level == level,
                        onTap: () => viewModel.setLevel(level)),
                  SizedBox(
                    height: 34,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: viewModel.location,
                        hint: const Text('Location', style: TextStyle(fontSize: 13)),
                        isDense: true,
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All locations')),
                          for (final location in viewModel.locations)
                            DropdownMenuItem(
                                value: location,
                                child: Text(location, style: const TextStyle(fontSize: 13))),
                        ],
                        onChanged: viewModel.setLocation,
                      ),
                    ),
                  ),
                  appFilterChip('Saved only (${viewModel.savedCount})',
                      selected: viewModel.savedOnly, onTap: viewModel.toggleSavedOnly,
                      icon: Icons.bookmark_border_rounded),
                  appFilterChip('Hide expired',
                      selected: viewModel.hideExpired, onTap: viewModel.toggleHideExpired,
                      icon: Icons.event_busy_outlined),
                  if (viewModel.filtersActive)
                    TextButton.icon(
                      onPressed: viewModel.clearFilters,
                      icon: const Icon(Icons.close_rounded, size: 16),
                      label: const Text('Clear', style: TextStyle(fontSize: 12.5)),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              if (results.isEmpty)
                const EmptyState(
                  icon: Icons.school_outlined,
                  title: 'No opportunities found',
                  message: 'Try clearing filters, or check the Saved only toggle.',
                )
              else
                ResponsiveBuilder(
                  builder: (context, type) {
                    final columns = switch (type) {
                      ScreenType.mobile => 1,
                      ScreenType.tablet => 2,
                      ScreenType.desktop => 2,
                    };
                    // Mobile cards are full-width and stack their pills onto
                    // multiple rows, so they need a much taller cell.
                    final aspectRatio = switch (type) {
                      ScreenType.mobile => 1.30,
                      ScreenType.tablet => 1.75,
                      ScreenType.desktop => 2.05,
                    };
                    return GridView.count(
                      crossAxisCount: columns,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: aspectRatio,
                      children: [
                        for (final opportunity in results)
                          OpportunityCard(
                            opportunity: opportunity,
                            onOpen: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    OpportunityDetailView(opportunityId: opportunity.id),
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
    );
  }
}
