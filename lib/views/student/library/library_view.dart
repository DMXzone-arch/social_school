import 'package:flutter/material.dart';

import '../../../core/widgets/responsive.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../models/enums.dart';
import '../../../models/resource.dart';
import '../../../repositories/library_repository.dart';
import '../../../viewmodels/library_viewmodel.dart';
import 'resource_detail_view.dart';
import 'widgets/resource_card.dart';

/// Digital library home: search, filters, sections and results.
class LibraryView extends StatelessWidget {
  const LibraryView({required this.viewModel, super.key});

  final LibraryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final showOverview = viewModel.tab == LibraryTab.all && !viewModel.filtersActive;
        final results = viewModel.results;

        return CenteredContent(
          maxWidth: 980,
          child: ListView(
            children: [
              const SizedBox(height: 4),
              AppSearchField(
                hint: 'Search books, notes, past papers…',
                controller: null,
                onChanged: viewModel.setQuery,
              ),
              const SizedBox(height: 12),

              // Tabs ----------------------------------------------------
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    appFilterChip('All', selected: viewModel.tab == LibraryTab.all,
                        onTap: () => viewModel.setTab(LibraryTab.all)),
                    const SizedBox(width: 8),
                    appFilterChip('Bookmarked (${viewModel.bookmarkCount})',
                        selected: viewModel.tab == LibraryTab.bookmarked,
                        onTap: () => viewModel.setTab(LibraryTab.bookmarked),
                        icon: Icons.bookmark_border_rounded),
                    const SizedBox(width: 8),
                    appFilterChip('Downloaded (${viewModel.downloadCount})',
                        selected: viewModel.tab == LibraryTab.downloaded,
                        onTap: () => viewModel.setTab(LibraryTab.downloaded),
                        icon: Icons.download_rounded),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Filters -------------------------------------------------
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (final level in EducationLevel.values)
                    appFilterChip(educationLevelLabel(level),
                        selected: viewModel.level == level,
                        onTap: () => viewModel.setLevel(level)),
                  _SubjectDropdown(viewModel: viewModel),
                  _CategoryDropdown(viewModel: viewModel),
                  if (viewModel.filtersActive)
                    TextButton.icon(
                      onPressed: viewModel.clearFilters,
                      icon: const Icon(Icons.close_rounded, size: 16),
                      label: const Text('Clear', style: TextStyle(fontSize: 12.5)),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              if (showOverview) ...[
                // Recently added ---------------------------------------
                if (viewModel.recentlyAdded.isNotEmpty) ...[
                  SectionHeader(
                    title: 'Recently added',
                    trailing: const DemoBadge(label: 'SAMPLE FILES'),
                  ),
                  SizedBox(
                    height: 258,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: viewModel.recentlyAdded.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final resource = viewModel.recentlyAdded[index];
                        return SizedBox(
                          width: 220,
                          child: ResourceCard(
                            resource: resource,
                            layout: ResourceLayout.grid,
                            onOpen: () => _open(context, resource),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Popular ------------------------------------------------
                if (viewModel.popular.isNotEmpty) ...[
                  const SectionHeader(title: 'Popular this week'),
                  for (final resource in viewModel.popular.take(3)) ...[
                    ResourceCard(
                      resource: resource,
                      layout: ResourceLayout.list,
                      onOpen: () => _open(context, resource),
                    ),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 16),
                ],
              ],

              // Results / all resources --------------------------------
              SectionHeader(
                title: showOverview
                    ? 'All resources'
                    : '${results.length} resource${results.length == 1 ? '' : 's'}',
                trailing: IconButton(
                  tooltip: viewModel.gridLayout ? 'List view' : 'Grid view',
                  onPressed: viewModel.toggleLayout,
                  icon: Icon(viewModel.gridLayout ? Icons.view_list_rounded : Icons.grid_view_rounded),
                ),
              ),
              if (results.isEmpty)
                EmptyState(
                  icon: Icons.menu_book_outlined,
                  title: viewModel.tab == LibraryTab.bookmarked
                      ? 'No bookmarks yet'
                      : viewModel.tab == LibraryTab.downloaded
                          ? 'No downloads yet'
                          : 'No resources found',
                  message: viewModel.tab == LibraryTab.bookmarked
                      ? 'Tap the bookmark icon on any resource to save it here.'
                      : viewModel.tab == LibraryTab.downloaded
                          ? 'Downloaded resources will be listed here.'
                          : 'Try clearing filters or search for something else.',
                )
              else if (viewModel.gridLayout)
                ResponsiveBuilder(
                  builder: (context, type) {
                    final columns = switch (type) {
                      ScreenType.mobile => 2,
                      ScreenType.tablet => 3,
                      ScreenType.desktop => 3,
                    };
                    // Taller cells on mobile so the card's stacked content
                    // (title, tags, meta, download button) never overflows.
                    final aspectRatio = switch (type) {
                      ScreenType.mobile => 0.52,
                      ScreenType.tablet => 0.66,
                      ScreenType.desktop => 0.78,
                    };
                    return GridView.count(
                      crossAxisCount: columns,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: aspectRatio,
                      children: [
                        for (final resource in results)
                          ResourceCard(
                            resource: resource,
                            layout: ResourceLayout.grid,
                            onOpen: () => _open(context, resource),
                          ),
                      ],
                    );
                  },
                )
              else
                for (final resource in results) ...[
                  ResourceCard(
                    resource: resource,
                    layout: ResourceLayout.list,
                    onOpen: () => _open(context, resource),
                  ),
                  const SizedBox(height: 10),
                ],
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  void _open(BuildContext context, LibraryResource resource) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ResourceDetailView(resourceId: resource.id)),
    );
  }
}

class _SubjectDropdown extends StatelessWidget {
  const _SubjectDropdown({required this.viewModel});

  final LibraryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: viewModel.subject,
          hint: const Text('Subject', style: TextStyle(fontSize: 13)),
          isDense: true,
          items: [
            const DropdownMenuItem(value: null, child: Text('All subjects')),
            for (final subject in viewModel.subjects)
              DropdownMenuItem(value: subject, child: Text(subject, style: const TextStyle(fontSize: 13))),
          ],
          onChanged: viewModel.setSubject,
        ),
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({required this.viewModel});

  final LibraryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ResourceCategory>(
          value: viewModel.category,
          hint: const Text('Category', style: TextStyle(fontSize: 13)),
          isDense: true,
          items: [
            const DropdownMenuItem(value: null, child: Text('All categories')),
            for (final category in ResourceCategory.values)
              DropdownMenuItem(
                value: category,
                child: Text(resourceCategoryLabel(category), style: const TextStyle(fontSize: 13)),
              ),
          ],
          onChanged: viewModel.setCategory,
        ),
      ),
    );
  }
}
