import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ui_kit.dart';

/// Reusable dashboard statistic card (all admin figures are demo data).
class StatCard extends StatelessWidget {
  const StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.caption,
    this.color = AppColors.primary,
    this.progress,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? caption;
  final Color color;

  /// Optional 0..1 progress bar (e.g. storage usage).
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return SSCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 19, color: color),
              ),
              const Spacer(),
              const DemoBadge(label: 'DEMO'),
            ],
          ),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.3)),
          if (progress != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress!.clamp(0, 1),
                minHeight: 6,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ],
          if (caption != null) ...[
            const SizedBox(height: 6),
            Text(caption!,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}
