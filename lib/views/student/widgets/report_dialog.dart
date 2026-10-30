import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/forms.dart';
import '../../../../core/widgets/ui_kit.dart';
import '../../../../models/enums.dart';
import '../../../../repositories/report_repository.dart';

/// Bridges feature widgets to the report repository without importing it
/// into every call site.
class AdminReportSink {
  AdminReportSink._();

  static final AdminReportSink instance = AdminReportSink._();

  void submit({
    required ReportTarget target,
    required String targetId,
    required String targetTitle,
    required ModerationReason reason,
  }) {
    ReportRepository.instance.createReport(
      target: target,
      targetId: targetId,
      targetTitle: targetTitle,
      reason: reason,
      reporter: 'Member',
    );
  }
}

/// Reusable report dialog used by posts, chats, resources and opportunities.
Future<void> showReportDialog(
  BuildContext context, {
  required String title,
  required void Function(ModerationReason reason, String notes) onSubmit,
  bool allowSuspiciousOpportunity = false,
}) async {
  var reason = ModerationReason.inappropriate;
  final notesController = TextEditingController();

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Reason', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final option in ModerationReason.values)
                    if (allowSuspiciousOpportunity ||
                        option != ModerationReason.suspiciousOpportunity)
                      appFilterChip(
                        moderationReasonLabel(option),
                        selected: reason == option,
                        onTap: () => setState(() => reason = option),
                      ),
                ],
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Additional details (optional)',
                hint: 'Anything the moderators should know…',
                controller: notesController,
                maxLines: 3,
              ),
              const SizedBox(height: 6),
              Text(
                'Reports are reviewed by a moderator. We will follow up if '
                'action is needed.',
                style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(dialogContext);
              onSubmit(reason, notesController.text.trim());
            },
            child: const Text('Submit report'),
          ),
        ],
      ),
    ),
  );
}
