import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/responsive.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../models/enums.dart';
import '../../../models/resource.dart';
import '../../../repositories/admin_repository.dart';
import '../../../repositories/library_repository.dart';
import '../student/library/mock_pdf_preview.dart';
import 'admin_shell.dart';
import 'resource_upload_view.dart';

/// Admin resource management: search, status filters and moderation actions.
class ResourcesView extends StatefulWidget {
  const ResourcesView({super.key});

  @override
  State<ResourcesView> createState() => _ResourcesViewState();
}

class _ResourcesViewState extends State<ResourcesView> {
  String _query = '';
  ResourceStatus? _status;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([LibraryRepository.instance, AdminRepository.instance]),
      builder: (context, _) {
        final resources = LibraryRepository.instance.resources.where((resource) {
          final matchesStatus = _status == null || resource.status == _status;
          final matchesQuery = _query.isEmpty ||
              resource.title.toLowerCase().contains(_query.toLowerCase()) ||
              resource.subject.toLowerCase().contains(_query.toLowerCase());
          return matchesStatus && matchesQuery;
        }).toList();

        return CenteredContent(
          maxWidth: 1200,
          child: ListView(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Resource Management',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.teal),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ResourceUploadView()),
                    ),
                    icon: const Icon(Icons.upload_file_rounded, size: 18),
                    label: const Text('Upload Resource'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Approving a resource publishes it to the student library instantly (shared demo state).',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: AppSearchField(
                      hint: 'Search by title or subject…',
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    appFilterChip('All', selected: _status == null,
                        onTap: () => setState(() => _status = null)),
                    for (final status in ResourceStatus.values) ...[
                      const SizedBox(width: 8),
                      appFilterChip(resourceStatusLabel(status),
                          selected: _status == status, onTap: () => setState(() => _status = status)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (resources.isEmpty)
                const EmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: 'No resources match',
                  message: 'Try clearing the search or choosing another status.',
                )
              else
                ResponsiveBuilder(
                  builder: (context, type) =>
                      type == ScreenType.desktop ? _table(resources) : _cards(resources),
                ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _table(List<LibraryResource> resources) {
    return SSCard(
      padding: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 22,
          headingTextStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
          columns: const [
            DataColumn(label: Text('Resource')),
            DataColumn(label: Text('Subject')),
            DataColumn(label: Text('Level')),
            DataColumn(label: Text('File')),
            DataColumn(label: Text('Submitted')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: [
            for (final resource in resources)
              DataRow(
                cells: [
                  DataCell(
                    SizedBox(
                      width: 220,
                      child: Text(resource.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  DataCell(Text(resource.subject, style: const TextStyle(fontSize: 13))),
                  DataCell(Text(educationLevelLabel(resource.level),
                      style: const TextStyle(fontSize: 12.5))),
                  DataCell(Text('${resource.fileType} · ${resource.fileSize}',
                      style: const TextStyle(fontSize: 12.5))),
                  DataCell(Text(formatDate(resource.dateAdded),
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary))),
                  DataCell(_StatusPillFor(status: resource.status)),
                  DataCell(_actionsMenu(resource: resource)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _cards(List<LibraryResource> resources) {
    return Column(
      children: [
        for (final resource in resources) ...[
          SSCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(resource.title,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    ),
                    _StatusPillFor(status: resource.status),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${resource.subject} · ${educationLevelLabel(resource.level)} · '
                  '${resource.fileType} · ${resource.fileSize} · added ${formatDate(resource.dateAdded)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                if (resource.rejectionReason != null) ...[
                  const SizedBox(height: 6),
                  Text('Reason: ${resource.rejectionReason}',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.error)),
                ],
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: _actionsFor(resource)),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  List<Widget> _actionsFor(LibraryResource resource) {
    final actions = <Widget>[
      _SmallAction(
        icon: Icons.visibility_outlined,
        label: 'Preview',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => MockPdfPreviewScreen(resource: resource)),
        ),
      ),
      _SmallAction(
        icon: Icons.edit_outlined,
        label: 'Edit',
        onTap: () => _showEditDialog(resource),
      ),
    ];

    if (resource.status == ResourceStatus.pendingReview ||
        resource.status == ResourceStatus.draft) {
      actions.addAll([
        _SmallAction(
          icon: Icons.check_circle_outline_rounded,
          label: 'Approve',
          color: AppColors.success,
          onTap: () {
            AdminRepository.instance.approveResource(resource.id);
            showAppSnackbar(context, 'Approved — now visible in the student library.');
          },
        ),
        _SmallAction(
          icon: Icons.cancel_outlined,
          label: 'Reject',
          color: AppColors.error,
          onTap: () => _showRejectDialog(resource),
        ),
      ]);
    }

    if (resource.status == ResourceStatus.approved) {
      actions.add(
        _SmallAction(
          icon: Icons.archive_outlined,
          label: 'Archive',
          onTap: () {
            AdminRepository.instance.archiveResource(resource.id);
            showAppSnackbar(context, 'Resource archived (removed from student library).');
          },
        ),
      );
    }

    if (resource.status == ResourceStatus.archived || resource.status == ResourceStatus.rejected) {
      actions.add(
        _SmallAction(
          icon: Icons.unarchive_outlined,
          label: 'Restore to approved',
          color: AppColors.success,
          onTap: () {
            AdminRepository.instance.restoreResource(resource.id);
            showAppSnackbar(context, 'Resource restored to approved.');
          },
        ),
      );
    }

    actions.add(
      _SmallAction(
        icon: Icons.delete_outline_rounded,
        label: 'Delete',
        color: AppColors.error,
        onTap: () async {
          final confirmed = await showAdminConfirm(
            context,
            title: 'Delete "${resource.title}"?',
            message: 'This removes the resource from the demo library entirely.',
            confirmLabel: 'Delete',
          );
          if (confirmed && mounted) {
            AdminRepository.instance.deleteResource(resource.id);
            showAppSnackbar(context, 'Resource deleted (demo).');
          }
        },
      ),
    );

    return actions;
  }

  Widget _actionsMenu({required LibraryResource resource}) {
    return PopupMenuButton<String>(
      tooltip: 'Actions',
      icon: const Icon(Icons.more_horiz_rounded, size: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        for (final action in _actionEntries(resource)) {
          if (action.$1 == value) action.$2();
        }
      },
      itemBuilder: (_) => [
        for (final action in _actionEntries(resource))
          PopupMenuItem(
            value: action.$1,
            child: Row(
              children: [
                Icon(action.$3, size: 17, color: action.$4 ?? AppColors.textPrimary),
                const SizedBox(width: 8),
                Text(action.$1, style: TextStyle(color: action.$4 ?? AppColors.textPrimary)),
              ],
            ),
          ),
      ],
    );
  }

  List<(String, VoidCallback, IconData, Color?)> _actionEntries(LibraryResource resource) {
    final entries = <(String, VoidCallback, IconData, Color?)>[
      (
        'Preview',
        () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => MockPdfPreviewScreen(resource: resource)),
        ),
        Icons.visibility_outlined,
        null,
      ),
      ('Edit metadata', () => _showEditDialog(resource), Icons.edit_outlined, null),
    ];

    if (resource.status == ResourceStatus.pendingReview || resource.status == ResourceStatus.draft) {
      entries.add((
        'Approve',
        () {
          AdminRepository.instance.approveResource(resource.id);
          showAppSnackbar(context, 'Approved — now visible in the student library.');
        },
        Icons.check_circle_outline_rounded,
        AppColors.success,
      ));
      entries.add(('Reject…', () => _showRejectDialog(resource), Icons.cancel_outlined, AppColors.error));
    }
    if (resource.status == ResourceStatus.approved) {
      entries.add((
        'Archive',
        () {
          AdminRepository.instance.archiveResource(resource.id);
          showAppSnackbar(context, 'Resource archived.');
        },
        Icons.archive_outlined,
        null,
      ));
    }
    if (resource.status == ResourceStatus.archived || resource.status == ResourceStatus.rejected) {
      entries.add((
        'Restore to approved',
        () {
          AdminRepository.instance.restoreResource(resource.id);
          showAppSnackbar(context, 'Resource restored.');
        },
        Icons.unarchive_outlined,
        AppColors.success,
      ));
    }
    entries.add((
      'Delete…',
      () async {
        final confirmed = await showAdminConfirm(
          context,
          title: 'Delete "${resource.title}"?',
          message: 'This removes the resource from the demo library entirely.',
          confirmLabel: 'Delete',
        );
        if (confirmed && mounted) {
          AdminRepository.instance.deleteResource(resource.id);
          showAppSnackbar(context, 'Resource deleted (demo).');
        }
      },
      Icons.delete_outline_rounded,
      AppColors.error,
    ));
    return entries;
  }

  void _showRejectDialog(LibraryResource resource) {
    final reasonController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reject resource'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rejecting "${resource.title}" keeps it unpublished in the student library.',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Reason for rejection (shown to the uploader)…',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              final reason = reasonController.text.trim();
              Navigator.pop(dialogContext);
              AdminRepository.instance.rejectResource(
                resource.id,
                reason.isEmpty ? 'No reason provided (demo).' : reason,
              );
              showAppSnackbar(context, 'Resource rejected (remains unpublished).');
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(LibraryResource resource) {
    final title = TextEditingController(text: resource.title);
    final subject = TextEditingController(text: resource.subject);
    final description = TextEditingController(text: resource.description);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit metadata'),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subject,
                decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: description,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.teal),
            onPressed: () {
              Navigator.pop(dialogContext);
              AdminRepository.instance.editResourceMetadata(
                resource.id,
                title: title.text,
                subject: subject.text,
                description: description.text,
              );
              showAppSnackbar(context, 'Metadata updated (demo).');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _StatusPillFor extends StatelessWidget {
  const _StatusPillFor({required this.status});

  final ResourceStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      ResourceStatus.draft => AppColors.textSecondary,
      ResourceStatus.pendingReview => const Color(0xFFB45309),
      ResourceStatus.approved => AppColors.success,
      ResourceStatus.rejected => AppColors.error,
      ResourceStatus.archived => AppColors.textSecondary,
    };
    return StatusPill(text: resourceStatusLabel(status), color: color);
  }
}

class _SmallAction extends StatelessWidget {
  const _SmallAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: c),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: c, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
