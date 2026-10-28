import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/responsive.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../repositories/admin_repository.dart';
import '../../../repositories/feed_repository.dart';
import '../../../repositories/library_repository.dart';
import '../../../repositories/notification_repository.dart';
import '../../../repositories/opportunity_repository.dart';
import 'widgets/stat_card.dart';

/// Admin dashboard: demo statistics and recent administrative activity.
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        AdminRepository.instance,
        LibraryRepository.instance,
        OpportunityRepository.instance,
        FeedRepository.instance,
        NotificationRepository.instance,
      ]),
      builder: (context, _) {
        final admin = AdminRepository.instance;
        final storageRatio = (admin.totalStorageMb / 1024).clamp(0.0, 1.0);

        return CenteredContent(
          maxWidth: 1100,
          child: ListView(
            children: [
              const Row(
                children: [
                  Expanded(
                    child: Text('Dashboard',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  ),
                  DemoBadge(label: 'ALL STATS ARE DEMO DATA'),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Figures below are simulated for the prototype — no real usage '
                'or cloud storage is being measured.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ResponsiveBuilder(
                builder: (context, type) {
                  final columns = switch (type) {
                    ScreenType.mobile => 2,
                    ScreenType.tablet => 3,
                    ScreenType.desktop => 4,
                  };
                  return GridView.count(
                    crossAxisCount: columns,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.15,
                    children: [
                      StatCard(
                        icon: Icons.people_alt_outlined,
                        label: 'Total students',
                        value: '${admin.totalStudents}',
                      ),
                      StatCard(
                        icon: Icons.online_prediction_rounded,
                        label: 'Active users (7d)',
                        value: '${admin.activeUsers}',
                        color: AppColors.teal,
                      ),
                      StatCard(
                        icon: Icons.inventory_2_outlined,
                        label: 'Published resources',
                        value: '${admin.publishedResources}',
                      ),
                      StatCard(
                        icon: Icons.pending_actions_outlined,
                        label: 'Pending approvals',
                        value: '${admin.pendingResources}',
                        color: const Color(0xFFB45309),
                        caption: admin.pendingResources == 0 ? 'Queue is clear' : 'Review queue',
                      ),
                      StatCard(
                        icon: Icons.school_outlined,
                        label: 'Published opportunities',
                        value: '${admin.publishedOpportunities}',
                        color: AppColors.teal,
                      ),
                      StatCard(
                        icon: Icons.flag_outlined,
                        label: 'Pending reports',
                        value: '${admin.pendingReports}',
                        color: AppColors.error,
                      ),
                      StatCard(
                        icon: Icons.folder_copy_outlined,
                        label: 'Mock storage usage',
                        value: '${admin.totalStorageMb.toStringAsFixed(1)} MB',
                        caption: 'Illustrative only — no real bucket',
                        progress: storageRatio,
                      ),
                      StatCard(
                        icon: Icons.trending_up_rounded,
                        label: 'Feed posts',
                        value: '${FeedRepository.instance.posts.length}',
                        color: AppColors.teal,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              // Recent activity ------------------------------------------
              ResponsiveBuilder(
                builder: (context, type) {
                  final wide = type == ScreenType.desktop;
                  final activity = SSCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.history_rounded, size: 18, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text('Recent administrative activity',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text('Simulated audit entries', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                        const Divider(height: 20),
                        if (admin.auditLog.isEmpty)
                          const EmptyState(icon: Icons.history_toggle_off, title: 'No activity yet')
                        else
                          for (final entry in admin.auditLog.take(6))
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.circle, size: 7, color: AppColors.teal),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(entry.action,
                                            style: const TextStyle(fontSize: 13, height: 1.35)),
                                        Text(
                                          '${entry.adminName} · ${formatDateTime(entry.timestamp)}',
                                          style: const TextStyle(
                                              fontSize: 11, color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      ],
                    ),
                  );

                  if (!wide) return activity;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: activity),
                      const SizedBox(width: 14),
                      Expanded(flex: 2, child: _StorageBreakdown(admin: admin)),
                    ],
                  );
                },
              ),
              if (screenTypeOf(context) != ScreenType.desktop) ...[
                const SizedBox(height: 14),
                _StorageBreakdown(admin: admin),
              ],
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}

class _StorageBreakdown extends StatelessWidget {
  const _StorageBreakdown({required this.admin});

  final AdminRepository admin;

  @override
  Widget build(BuildContext context) {
    final distribution = admin.fileTypeDistribution;
    final max = distribution.values.fold<double>(0, (a, b) => a > b ? a : b);

    return SSCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.pie_chart_outline_rounded, size: 18, color: AppColors.teal),
              SizedBox(width: 8),
              Text('File type distribution',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Illustrative storage figures',
              style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
          const Divider(height: 20),
          if (distribution.isEmpty)
            const EmptyState(icon: Icons.folder_off_outlined, title: 'No files yet')
          else
            for (final entry in distribution.entries) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(entry.key, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Text('${entry.value.toStringAsFixed(1)} MB',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: max == 0 ? 0 : entry.value / max,
                        minHeight: 6,
                        backgroundColor: AppColors.border,
                        valueColor: const AlwaysStoppedAnimation(AppColors.teal),
                      ),
                    ),
                  ],
                ),
              ),
            ],
        ],
      ),
    );
  }
}
