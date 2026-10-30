import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/forms.dart';
import '../../../core/widgets/responsive.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../models/enums.dart';
import '../../../repositories/opportunity_repository.dart';
import '../widgets/report_dialog.dart';

/// Full details of an opportunity listing (all demo data).
class OpportunityDetailView extends StatelessWidget {
  const OpportunityDetailView({required this.opportunityId, super.key});

  final String opportunityId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: OpportunityRepository.instance,
      builder: (context, _) {
        final o = OpportunityRepository.instance.byId(opportunityId);
        if (o == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Opportunity')),
            body: const EmptyState(
              icon: Icons.school_outlined,
              title: 'Listing not available',
              message: 'This listing is no longer available.',
            ),
          );
        }

        final deadlineDays = daysUntil(o.deadline);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Opportunity details'),
            actions: [
              IconButton(
                tooltip: o.saved ? 'Remove from saved' : 'Save opportunity',
                onPressed: () => OpportunityRepository.instance.toggleSave(o.id),
                icon: Icon(
                  o.saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: o.saved ? AppColors.gold : null,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: CenteredContent(
            maxWidth: 760,
            child: ListView(
              children: [
                if (o.isExpired)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.event_busy_rounded, color: AppColors.error, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'This listing has expired — applications closed on the '
                            'deadline date.',
                            style: TextStyle(fontSize: 12.5, color: AppColors.error, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),

                SSCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(o.title,
                                          style: const TextStyle(
                                              fontSize: 18, fontWeight: FontWeight.w800, height: 1.3)),
                                    ),
                                    if (o.verified) ...[
                                      const SizedBox(width: 6),
                                      const Tooltip(
                                        message: 'Verified listing',
                                        child: Icon(Icons.verified_rounded,
                                            size: 18, color: AppColors.primary),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(o.provider,
                                    style: TextStyle(
                                        fontSize: 13.5, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          const DemoBadge(),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          StatusPill(
                              text: opportunityCategoryLabel(o.category), color: AppColors.teal),
                          StatusPill(text: educationLevelLabel(o.level), color: AppColors.primary),
                          StatusPill(
                            text: o.isExpired
                                ? 'Expired'
                                : 'Deadline in $deadlineDays day${deadlineDays == 1 ? '' : 's'}',
                            color: o.isExpired
                                ? AppColors.error
                                : deadlineDays <= 14
                                    ? const Color(0xFFB45309)
                                    : AppColors.success,
                          ),
                        ],
                      ),
                      const Divider(height: 28),
                      const SectionHeader(title: 'About this opportunity'),
                      Text(o.description,
                          style: const TextStyle(fontSize: 13.5, height: 1.6)),
                      const SizedBox(height: 16),
                      const SectionHeader(title: 'Eligibility criteria'),
                      Text(o.eligibility,
                          style: const TextStyle(fontSize: 13.5, height: 1.6)),
                      const SizedBox(height: 16),
                      const SectionHeader(title: 'Required documents'),
                      for (final document in o.requiredDocuments)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline_rounded,
                                  size: 16, color: AppColors.teal),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(document, style: const TextStyle(fontSize: 13.5)),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      InfoRow(
                        icon: Icons.event_rounded,
                        label: 'Application deadline',
                        value: formatDate(o.deadline),
                      ),
                      InfoRow(
                        icon: o.remote ? Icons.language_rounded : Icons.location_on_outlined,
                        label: 'Location',
                        value: o.location,
                      ),
                      const Divider(height: 28),
                      const SectionHeader(title: 'How to apply'),
                      Text(o.instructions, style: const TextStyle(fontSize: 13.5, height: 1.6)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.link_off_rounded, size: 18, color: Color(0xFF8A6100)),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Applications for this listing are currently '
                                'closed, so no application link is available.',
                                style: TextStyle(fontSize: 12.5, color: Color(0xFF8A6100), height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: o.saved ? 'Saved ✓' : 'Save opportunity',
                              icon: Icons.bookmark_rounded,
                              onPressed: o.isExpired
                                  ? null
                                  : () => OpportunityRepository.instance.toggleSave(o.id),
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () => showReportDialog(
                          context,
                          title: 'Report this listing',
                          allowSuspiciousOpportunity: true,
                          onSubmit: (reason, notes) {
                            OpportunityRepository.instance.markReported(o.id);
                            AdminReportSink.instance.submit(
                              target: ReportTarget.opportunity,
                              targetId: o.id,
                              targetTitle: o.title,
                              reason: reason,
                            );
                            showAppSnackbar(context, 'Listing reported for review.');
                          },
                        ),
                        icon: const Icon(Icons.flag_outlined, size: 16, color: AppColors.error),
                        label: const Text('Report listing',
                            style: TextStyle(fontSize: 12.5, color: AppColors.error)),
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
