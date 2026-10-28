import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/responsive.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../models/admin.dart';
import '../../../models/enums.dart';
import '../../../repositories/admin_repository.dart';

/// Admin reports & moderation queue: open reports with a detail panel.
class ReportsView extends StatefulWidget {
  const ReportsView({super.key});

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> {
  ReportStatus? _status = ReportStatus.open;
  String? _selectedReportId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminRepository.instance,
      builder: (context, _) {
        final reports = AdminRepository.instance.reports
            .where((r) => _status == null || r.status == _status)
            .toList();
        final selected = _selectedReportId == null
            ? null
            : AdminRepository.instance.reportById(_selectedReportId!);

        return CenteredContent(
          maxWidth: 1150,
          child: ListView(
            children: [
              const Text('Reports & Moderation',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text(
                'Reports raised by students in the demo. Resolving or dismissing is simulated.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  appFilterChip('Open', selected: _status == ReportStatus.open,
                      onTap: () => setState(() => _status = ReportStatus.open)),
                  const SizedBox(width: 8),
                  appFilterChip('Resolved', selected: _status == ReportStatus.resolved,
                      onTap: () => setState(() => _status = ReportStatus.resolved)),
                  const SizedBox(width: 8),
                  appFilterChip('Dismissed', selected: _status == ReportStatus.dismissed,
                      onTap: () => setState(() => _status = ReportStatus.dismissed)),
                  const SizedBox(width: 8),
                  appFilterChip('All', selected: _status == null,
                      onTap: () => setState(() => _status = null)),
                ],
              ),
              const SizedBox(height: 14),
              if (reports.isEmpty)
                const EmptyState(
                  icon: Icons.flag_outlined,
                  title: 'No reports in this view',
                  message: 'Reports raised from posts or conversations appear here.',
                )
              else
                ResponsiveBuilder(
                  builder: (context, type) {
                    if (type == ScreenType.desktop) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: _table(reports)),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: _detailPanel(selected ??
                                (reports.isEmpty ? null : reports.first)),
                          ),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        for (final report in reports) ...[
                          _reportCard(report, showActions: true),
                          const SizedBox(height: 10),
                        ],
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

  Color _statusColor(ReportStatus status) => switch (status) {
        ReportStatus.open => AppColors.gold,
        ReportStatus.resolved => AppColors.success,
        ReportStatus.dismissed => AppColors.textSecondary,
      };

  Widget _table(List<Report> reports) {
    return SSCard(
      padding: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 22,
          headingTextStyle: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
          columns: const [
            DataColumn(label: Text('Target')),
            DataColumn(label: Text('Reason')),
            DataColumn(label: Text('Reporter')),
            DataColumn(label: Text('Raised')),
            DataColumn(label: Text('Status')),
          ],
          rows: [
            for (final report in reports)
              DataRow(
                selected: report.id == _selectedReportId,
                onSelectChanged: (_) => setState(() => _selectedReportId = report.id),
                cells: [
                  DataCell(SizedBox(
                    width: 220,
                    child: Text(
                      '${reportTargetLabel(report.target)}: ${report.targetTitle}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                  )),
                  DataCell(Text(moderationReasonLabel(report.reason),
                      style: const TextStyle(fontSize: 12.5))),
                  DataCell(Text(report.reporter, style: const TextStyle(fontSize: 12.5))),
                  DataCell(Text(timeAgo(report.timestamp),
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                  DataCell(StatusPill(
                      text: reportStatusLabel(report.status), color: _statusColor(report.status))),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _detailPanel(Report? report) {
    if (report == null) return const SizedBox.shrink();
    return _reportCard(report, showActions: true, elevated: true);
  }

  Widget _reportCard(Report report, {required bool showActions, bool elevated = false}) {
    return SSCard(
      padding: const EdgeInsets.all(16),
      color: elevated ? AppColors.white : AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${reportTargetLabel(report.target)} report',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
              StatusPill(
                  text: reportStatusLabel(report.status), color: _statusColor(report.status)),
            ],
          ),
          const SizedBox(height: 10),
          InfoRow(icon: Icons.flag_outlined, label: 'Target', value: report.targetTitle),
          InfoRow(icon: Icons.rule_outlined, label: 'Reason', value: moderationReasonLabel(report.reason)),
          InfoRow(icon: Icons.person_outline_rounded, label: 'Reported by', value: report.reporter),
          InfoRow(icon: Icons.schedule_rounded, label: 'Raised', value: formatDateTime(report.timestamp)),
          if (report.notes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('Notes: ${report.notes}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ),
            ),
          if (showActions && report.status == ReportStatus.open) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.teal),
                    onPressed: () => _resolve(report),
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Resolve'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                    ),
                    onPressed: () => _dismiss(report),
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text('Dismiss'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _resolve(Report report) async {
    final notes = await _notesDialog(
      title: 'Resolve report',
      hint: 'e.g. Post removed and student warned (simulated).',
    );
    if (notes == null || !mounted) return;
    AdminRepository.instance.resolveReport(report.id, notes);
    showAppSnackbar(context, 'Report resolved (demo).');
  }

  Future<void> _dismiss(Report report) async {
    final notes = await _notesDialog(
      title: 'Dismiss report',
      hint: 'e.g. No violation found after review.',
    );
    if (notes == null || !mounted) return;
    AdminRepository.instance.dismissReport(report.id, notes);
    showAppSnackbar(context, 'Report dismissed (demo).');
  }

  Future<String?> _notesDialog({required String title, required String hint}) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: SizedBox(
          width: 420,
          child: TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Moderation notes',
              hintText: hint,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.teal),
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim().isEmpty
                    ? 'Reviewed in demo'
                    : controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
