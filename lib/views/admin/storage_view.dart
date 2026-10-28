import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../data/demo_state_store.dart';
import '../../../repositories/admin_repository.dart';
import '../../../repositories/library_repository.dart';
import 'admin_shell.dart';
import 'widgets/stat_card.dart';

/// Illustrative storage overview + prototype settings (reset demo data).
///
/// All figures are simulated from the mock file sizes — no real cloud
/// storage bucket exists in this prototype.
class StorageView extends StatelessWidget {
  const StorageView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([AdminRepository.instance, LibraryRepository.instance]),
      builder: (context, _) {
        final admin = AdminRepository.instance;
        final resources = LibraryRepository.instance.resources;
        final distribution = admin.fileTypeDistribution;
        final totalMb = admin.totalStorageMb;
        final maxMb = distribution.values.fold<double>(0, (a, b) => a > b ? a : b);

        return CenteredContent(
          maxWidth: 1000,
          child: ListView(
            children: [
              const Text('Storage & Settings',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text(
                'Simulated figures derived from mock file sizes — there is no real '
                'storage bucket in this prototype.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ResponsiveBuilder(
                builder: (context, type) {
                  final crossAxisCount = switch (type) {
                    ScreenType.mobile => 2,
                    ScreenType.tablet => 3,
                    ScreenType.desktop => 4,
                  };
                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.1,
                    children: [
                      StatCard(
                        label: 'Files stored',
                        value: '${resources.length}',
                        icon: Icons.folder_open_rounded,
                        color: AppColors.primary,
                      ),
                      StatCard(
                        label: 'Total size',
                        value: '${totalMb.toStringAsFixed(1)} MB',
                        icon: Icons.cloud_off_outlined,
                        color: AppColors.teal,
                      ),
                      StatCard(
                        label: 'Avg. file size',
                        value: '${admin.averageFileMb.toStringAsFixed(1)} MB',
                        icon: Icons.insert_drive_file_outlined,
                        color: AppColors.gold,
                      ),
                      StatCard(
                        label: 'Pending review',
                        value: '${admin.pendingResources}',
                        icon: Icons.hourglass_bottom_rounded,
                        color: AppColors.error,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              SSCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('File type distribution',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    const Text(
                      'Illustrative breakdown by mock file size (DEMO).',
                      style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    for (final entry in distribution.entries) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(entry.key,
                                    style: const TextStyle(
                                        fontSize: 13, fontWeight: FontWeight.w700)),
                                const Spacer(),
                                Text('${entry.value.toStringAsFixed(1)} MB',
                                    style: const TextStyle(
                                        fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: maxMb == 0 ? 0 : entry.value / maxMb,
                                minHeight: 8,
                                backgroundColor: AppColors.background,
                                valueColor:
                                    const AlwaysStoppedAnimation(AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SSCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Prototype data',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    const Text(
                      'The demo state lives in this device/browser local storage only — '
                      'nothing is uploaded anywhere. Resetting reseeds all fictional '
                      'content (posts, resources, chats, opportunities, reports).',
                      style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.45),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
                          ),
                          onPressed: () async {
                            final confirmed = await showAdminConfirm(
                              context,
                              title: 'Reset all demo data?',
                              message:
                                  'Every simulated change is discarded and the original '
                                  'fictional sample data is restored in both apps.',
                              confirmLabel: 'Reset demo data',
                            );
                            if (!confirmed || !context.mounted) return;
                            DemoStateStore.instance.resetDemoData();
                            showAppSnackbar(context, 'Demo data reset to the original sample set.');
                          },
                          icon: const Icon(Icons.restart_alt_rounded, size: 17),
                          label: const Text('Reset demo data'),
                        ),
                        const SizedBox(width: 12),
                        const DemoBadge(label: 'DEMO'),
                      ],
                    ),
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
