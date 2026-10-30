import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../models/enums.dart';
import '../../../../models/resource.dart';
import '../../../../repositories/library_repository.dart';

/// Reusable download control that reflects the simulated download state
/// (idle → downloading with progress → downloaded / failed with retry).
/// Used by resource cards and the resource detail screen.
class DownloadButton extends StatelessWidget {
  const DownloadButton({
    required this.resource,
    this.compact = false,
    this.showRemoveWhenDone = true,
    super.key,
  });

  final LibraryResource resource;
  final bool compact;
  final bool showRemoveWhenDone;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LibraryRepository.instance,
      builder: (context, _) {
        final repo = LibraryRepository.instance;

        switch (resource.downloadState) {
          case DownloadState.none:
            return _pillButton(
              context,
              icon: Icons.download_rounded,
              label: compact ? '' : 'Download',
              color: AppColors.primary,
              filled: true,
              onTap: () => repo.startDownload(resource.id),
            );

          case DownloadState.downloading:
            final percent = (resource.downloadProgress * 100).clamp(0, 100).round();
            return _pillButton(
              context,
              icon: null,
              label: compact ? '$percent%' : 'Downloading… $percent%',
              color: AppColors.primary,
              filled: false,
              leading: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: resource.downloadProgress.clamp(0, 1),
                  color: AppColors.primary,
                ),
              ),
              onTap: () {},
            );

          case DownloadState.downloaded:
            return _pillButton(
              context,
              icon: Icons.check_circle_rounded,
              label: compact ? '' : 'Downloaded',
              color: AppColors.success,
              filled: false,
              onTap: showRemoveWhenDone
                  ? () => repo.removeDownload(resource.id)
                  : () {},
              tooltip: showRemoveWhenDone ? 'Remove from downloads' : null,
            );

          case DownloadState.failed:
            return _pillButton(
              context,
              icon: Icons.refresh_rounded,
              label: compact ? 'Retry' : 'Download failed — Retry',
              color: AppColors.error,
              filled: false,
              onTap: () => repo.startDownload(resource.id),
            );
        }
      },
    );
  }

  Widget _pillButton(
    BuildContext context, {
    required IconData? icon,
    required String label,
    required Color color,
    required bool filled,
    required VoidCallback onTap,
    Widget? leading,
    String? tooltip,
  }) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[leading, const SizedBox(width: 6)],
        if (icon != null) Icon(icon, size: 16),
        if (icon != null && label.isNotEmpty) const SizedBox(width: 5),
        if (label.isNotEmpty)
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );

    final button = filled
        ? FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              minimumSize: const Size(40, 36),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
            ),
            onPressed: onTap,
            child: child,
          )
        : OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: color,
              minimumSize: const Size(40, 36),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              side: BorderSide(color: color.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
            ),
            onPressed: onTap,
            child: child,
          );

    return tooltip == null ? button : Tooltip(message: tooltip, child: button);
  }
}

/// Reusable bookmark toggle used across the library and profile.
class BookmarkButton extends StatelessWidget {
  const BookmarkButton({required this.resourceId, this.withLabel = false, super.key});

  final String resourceId;
  final bool withLabel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LibraryRepository.instance,
      builder: (context, _) {
        final resource = LibraryRepository.instance.byId(resourceId);
        final bookmarked = resource?.bookmarked ?? false;
        return IconButton(
          tooltip: bookmarked ? 'Remove bookmark' : 'Bookmark',
          onPressed: () => LibraryRepository.instance.toggleBookmark(resourceId),
          icon: Icon(
            bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            color: bookmarked ? AppColors.gold : AppColors.textSecondary,
            size: 22,
          ),
        );
      },
    );
  }
}
