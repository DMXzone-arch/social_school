import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/responsive.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../models/enums.dart';
import '../../../repositories/library_repository.dart';
import '../widgets/report_dialog.dart';
import 'mock_pdf_preview.dart';
import 'widgets/download_button.dart';

/// Resource details with download, bookmark, preview and report actions.
class ResourceDetailView extends StatelessWidget {
  const ResourceDetailView({required this.resourceId, super.key});

  final String resourceId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LibraryRepository.instance,
      builder: (context, _) {
        final resource = LibraryRepository.instance.byId(resourceId);
        if (resource == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Resource')),
            body: const EmptyState(
              icon: Icons.delete_outline_rounded,
              title: 'Resource not available',
              message: 'This resource is no longer available.',
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Resource details'),
            actions: [BookmarkButton(resourceId: resource.id), const SizedBox(width: 8)],
          ),
          body: CenteredContent(
            maxWidth: 760,
            child: ListView(
              children: [
                SSCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.description_rounded, color: AppColors.error, size: 30),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(resource.title,
                                    style: const TextStyle(
                                        fontSize: 18, fontWeight: FontWeight.w800, height: 1.3)),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    StatusPill(text: resource.subject, color: AppColors.teal),
                                    StatusPill(text: resourceCategoryLabel(resource.category),
                                        color: AppColors.primary),
                                    StatusPill(text: educationLevelLabel(resource.level),
                                        color: const Color(0xFFB45309)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(resource.description,
                          style: const TextStyle(fontSize: 14, height: 1.6, color: AppColors.textPrimary)),
                      const Divider(height: 28),
                      InfoRow(icon: Icons.person_outline_rounded, label: 'Author / source', value: resource.author),
                      InfoRow(icon: Icons.school_outlined, label: 'Intended for',
                          value: '${educationLevelLabel(resource.level)} · ${resource.institution}'),
                      InfoRow(icon: Icons.insert_drive_file_outlined, label: 'File',
                          value: '${resource.fileType} · ${resource.fileSize}'),
                      InfoRow(icon: Icons.calendar_today_outlined, label: 'Date added',
                          value: formatDate(resource.dateAdded)),
                      InfoRow(icon: Icons.download_rounded, label: 'Downloads',
                          value: '${resource.downloadCount}'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: DownloadButton(resource: resource, showRemoveWhenDone: true)),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              minimumSize: const Size(0, 44),
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MockPdfPreviewScreen(resource: resource),
                              ),
                            ),
                            icon: const Icon(Icons.menu_book_outlined, size: 18),
                            label: const Text('Preview'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SSCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.verified_user_outlined, size: 18, color: AppColors.teal),
                          SizedBox(width: 8),
                          Text('About this resource',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Download and study this resource offline. Files are '
                        'provided by your school and partner institutions.',
                        style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.5),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => showReportDialog(
                            context,
                            title: 'Report this resource',
                            allowSuspiciousOpportunity: true,
                            onSubmit: (reason, notes) {
                              AdminReportSink.instance.submit(
                                target: ReportTarget.resource,
                                targetId: resource.id,
                                targetTitle: resource.title,
                                reason: reason,
                              );
                              showAppSnackbar(context, 'Report submitted for review.');
                            },
                          ),
                          icon: const Icon(Icons.flag_outlined, size: 16, color: AppColors.error),
                          label: const Text('Report this resource',
                              style: TextStyle(fontSize: 12.5, color: AppColors.error)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}
