import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/responsive.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../models/admin.dart';
import '../../../repositories/admin_repository.dart';

/// Read-only audit log of simulated administrator actions.
class AuditLogView extends StatelessWidget {
  const AuditLogView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminRepository.instance,
      builder: (context, _) {
        final entries = AdminRepository.instance.auditLog;

        return CenteredContent(
          maxWidth: 1000,
          child: ListView(
            children: [
              const Text('Audit Log',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text(
                'Every administrative action taken in this demo session, newest first.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              if (entries.isEmpty)
                const EmptyState(
                  icon: Icons.history_rounded,
                  title: 'No entries yet',
                  message: 'Admin actions (approvals, announcements…) are logged here.',
                )
              else
                SSCard(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    children: [
                      for (var i = 0; i < entries.length; i++) ...[
                        _AuditTile(entry: entries[i], isLast: i == entries.length - 1),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}

class _AuditTile extends StatelessWidget {
  const _AuditTile({required this.entry, required this.isLast});

  final AuditEntry entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, type) {
        final subtitle = type == ScreenType.mobile
            ? '${entry.adminName}\n${formatDateTime(entry.timestamp)}'
            : '${entry.adminName} · ${formatDateTime(entry.timestamp)}';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          child: Column(
            children: [
              ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.teal.withValues(alpha: 0.12),
                  child: const Icon(Icons.admin_panel_settings_rounded,
                      size: 16, color: AppColors.teal),
                ),
                title: Text(entry.action,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                subtitle: Text(subtitle,
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
              ),
              if (!isLast) const Divider(height: 1, indent: 46),
            ],
          ),
        );
      },
    );
  }
}
