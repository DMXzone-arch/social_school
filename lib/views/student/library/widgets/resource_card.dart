import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/ui_kit.dart';
import '../../../../models/enums.dart';
import '../../../../models/resource.dart';
import 'download_button.dart';

/// Reusable library resource card with grid and list layouts.
/// Used by the library home, search results, bookmarks, downloads
/// and the profile's saved resources tab.
class ResourceCard extends StatelessWidget {
  const ResourceCard({
    required this.resource,
    required this.onOpen,
    this.layout = ResourceLayout.grid,
    super.key,
  });

  final LibraryResource resource;
  final VoidCallback onOpen;
  final ResourceLayout layout;

  @override
  Widget build(BuildContext context) {
    return layout == ResourceLayout.grid ? _grid(context) : _list(context);
  }

  Widget _grid(BuildContext context) {
    return SSCard(
      onTap: onOpen,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _FileBadge(),
              const Spacer(),
              BookmarkButton(resourceId: resource.id),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            resource.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, height: 1.3),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              StatusPill(text: resource.subject, color: AppColors.teal),
              StatusPill(text: educationLevelLabel(resource.level), color: AppColors.primary),
            ],
          ),
          const Spacer(),
          Text(
            '${resource.fileType} · ${resource.fileSize} · ${formatDate(resource.dateAdded)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: DownloadButton(resource: resource)),
              const SizedBox(width: 6),
              Text('${resource.downloadCount} ⬇',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _list(BuildContext context) {
    return SSCard(
      onTap: onOpen,
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FileBadge(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(resource.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  '${resource.subject} · ${educationLevelLabel(resource.level)} · '
                  '${resource.fileType} · ${resource.fileSize}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: DownloadButton(resource: resource)),
                    const SizedBox(width: 4),
                    BookmarkButton(resourceId: resource.id),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Layout variants for [ResourceCard].
enum ResourceLayout { grid, list }

class _FileBadge extends StatelessWidget {
  const _FileBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.description_outlined, color: AppColors.error, size: 22),
    );
  }
}
