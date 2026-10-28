import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/ui_kit.dart';
import '../../../../models/enums.dart';
import '../../../../models/opportunity.dart';
import '../../../../repositories/opportunity_repository.dart';

/// Reusable opportunity card used by the opportunities list and the
/// profile's saved listings.
class OpportunityCard extends StatelessWidget {
  const OpportunityCard({required this.opportunity, required this.onOpen, super.key});

  final Opportunity opportunity;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final o = opportunity;
    final deadlineDays = daysUntil(o.deadline);

    return SSCard(
      onTap: onOpen,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_categoryIcon(o.category), color: AppColors.teal, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(o.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                        ),
                        if (o.verified) ...[
                          const SizedBox(width: 5),
                          const Tooltip(
                            message: 'Verified listing',
                            child: Icon(Icons.verified_rounded, size: 15, color: AppColors.primary),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(o.provider,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              IconButton(
                tooltip: o.saved ? 'Remove from saved' : 'Save',
                onPressed: () => OpportunityRepository.instance.toggleSave(o.id),
                icon: Icon(
                  o.saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: o.saved ? AppColors.gold : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              StatusPill(text: opportunityCategoryLabel(o.category), color: AppColors.teal),
              StatusPill(text: educationLevelLabel(o.level), color: AppColors.primary),
              StatusPill(
                text: o.isExpired ? 'Expired' : 'Closes ${formatDate(o.deadline)}',
                color: o.isExpired
                    ? AppColors.error
                    : deadlineDays <= 14
                        ? const Color(0xFFB45309)
                        : AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(o.remote ? Icons.language_rounded : Icons.location_on_outlined,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(o.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ),
              const DemoBadge(),
            ],
          ),
        ],
      ),
    );
  }

  static IconData _categoryIcon(OpportunityCategory category) => switch (category) {
        OpportunityCategory.scholarship => Icons.school_rounded,
        OpportunityCategory.internship => Icons.work_outline_rounded,
        OpportunityCategory.competition => Icons.emoji_events_outlined,
        OpportunityCategory.training => Icons.trending_up_rounded,
        OpportunityCategory.conference => Icons.groups_outlined,
        OpportunityCategory.youthProgramme => Icons.auto_awesome_rounded,
      };
}
