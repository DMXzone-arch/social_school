import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/responsive.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../models/enums.dart';
import '../../../models/opportunity.dart';
import '../../../repositories/admin_repository.dart';
import '../../../repositories/opportunity_repository.dart';
import 'admin_shell.dart';

/// Admin opportunities management: create, publish, verify, expire listings.
class OpportunitiesManagementView extends StatefulWidget {
  const OpportunitiesManagementView({super.key});

  @override
  State<OpportunitiesManagementView> createState() => _OpportunitiesManagementViewState();
}

class _OpportunitiesManagementViewState extends State<OpportunitiesManagementView> {
  bool _showExpiredOnly = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([OpportunityRepository.instance, AdminRepository.instance]),
      builder: (context, _) {
        final all = OpportunityRepository.instance.opportunities;
        final listings = _showExpiredOnly ? all.where((o) => o.isExpired).toList() : all;

        return CenteredContent(
          maxWidth: 1100,
          child: ListView(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Opportunities Management',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.teal),
                    onPressed: () => _showCreateDialog(),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Create opportunity'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Publishing a listing makes it visible in the student Opportunities section (demo).',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              appFilterChip('Show expired only',
                  selected: _showExpiredOnly, onTap: () => setState(() => _showExpiredOnly = !_showExpiredOnly)),
              const SizedBox(height: 14),
              if (listings.isEmpty)
                const EmptyState(
                  icon: Icons.school_outlined,
                  title: 'No listings',
                  message: 'Create the first opportunity listing.',
                )
              else
                for (final opportunity in listings) ...[
                  _OpportunityAdminCard(opportunity: opportunity),
                  const SizedBox(height: 10),
                ],
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  void _showCreateDialog() {
    final title = TextEditingController();
    final provider = TextEditingController();
    final eligibility = TextEditingController();
    final location = TextEditingController();
    final description = TextEditingController();
    final instructions = TextEditingController();
    var category = OpportunityCategory.scholarship;
    var level = EducationLevel.university;
    var deadline = DateTime.now().add(const Duration(days: 45));
    var published = true;
    var verified = false;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Create opportunity'),
          content: SizedBox(
            width: 520,
            height: 520,
            child: ListView(
              children: [
                TextField(
                  controller: title,
                  decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: provider,
                  decoration: const InputDecoration(
                      labelText: 'Provider (fictional)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<OpportunityCategory>(
                        initialValue: category,
                        decoration: const InputDecoration(
                            labelText: 'Category', border: OutlineInputBorder(), isDense: true),
                        items: [
                          for (final c in OpportunityCategory.values)
                            DropdownMenuItem(value: c, child: Text(opportunityCategoryLabel(c))),
                        ],
                        onChanged: (v) => setState(() => category = v ?? category),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<EducationLevel>(
                        initialValue: level,
                        decoration: const InputDecoration(
                            labelText: 'Level', border: OutlineInputBorder(), isDense: true),
                        items: [
                          for (final l in EducationLevel.values)
                            DropdownMenuItem(value: l, child: Text(educationLevelLabel(l))),
                        ],
                        onChanged: (v) => setState(() => level = v ?? level),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: eligibility,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      labelText: 'Eligibility summary', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: location,
                  decoration: const InputDecoration(
                      labelText: 'Location (or "Remote")', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: description,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      labelText: 'Full description', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: instructions,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      labelText: 'Application instructions', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_rounded),
                  title: Text('Deadline: ${formatDate(deadline)}'),
                  trailing: TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: dialogContext,
                        initialDate: deadline,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 730)),
                      );
                      if (picked != null) setState(() => deadline = picked);
                    },
                    child: const Text('Change'),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: published,
                  onChanged: (v) => setState(() => published = v),
                  title: const Text('Publish immediately'),
                  subtitle: const Text('Off = draft, hidden from students',
                      style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: verified,
                  onChanged: (v) => setState(() => verified = v),
                  title: const Text('Mark as verified (demo)'),
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
              onPressed: () async {
                if (title.text.trim().isEmpty || provider.text.trim().isEmpty) {
                  showAppSnackbar(context, 'Title and provider are required.', error: true);
                  return;
                }
                Navigator.pop(dialogContext);
                await AdminRepository.instance.createOpportunity(
                  Opportunity(
                    id: 'o${DateTime.now().millisecondsSinceEpoch}',
                    title: title.text.trim(),
                    provider: provider.text.trim(),
                    category: category,
                    level: level,
                    eligibility: eligibility.text.trim().isEmpty
                        ? 'See full description (demo).'
                        : eligibility.text.trim(),
                    deadline: deadline,
                    location: location.text.trim().isEmpty ? 'Malawi (demo)' : location.text.trim(),
                    description: description.text.trim().isEmpty
                        ? 'Demo listing created in the admin app.'
                        : description.text.trim(),
                    requiredDocuments: const ['Application form (demo)'],
                    instructions: instructions.text.trim().isEmpty
                        ? 'Demo listing — no live application channel exists.'
                        : instructions.text.trim(),
                    verified: verified,
                    published: published,
                  ),
                );
                if (mounted) {
                  showAppSnackbar(
                    context,
                    published
                        ? 'Opportunity published — now visible in the student app.'
                        : 'Draft saved — publish it to show it to students.',
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpportunityAdminCard extends StatelessWidget {
  const _OpportunityAdminCard({required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    final o = opportunity;

    return SSCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(o.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    Text(o.provider,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              StatusPill(
                text: o.published ? 'Published' : 'Draft',
                color: o.published ? AppColors.success : AppColors.textSecondary,
              ),
              if (o.isExpired) ...[
                const SizedBox(width: 6),
                const StatusPill(text: 'Expired', color: AppColors.error),
              ],
              if (o.verified) ...[
                const SizedBox(width: 6),
                const StatusPill(text: 'Verified', color: AppColors.primary),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${opportunityCategoryLabel(o.category)} · ${educationLevelLabel(o.level)} · '
            '${o.location} · deadline ${formatDate(o.deadline)}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size(0, 34),
                  side: const BorderSide(color: AppColors.primary),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                onPressed: () {
                  o.published
                      ? AdminRepository.instance.unpublishOpportunity(o.id)
                      : AdminRepository.instance.publishOpportunity(o.id);
                  showAppSnackbar(
                    context,
                    o.published ? 'Listing unpublished.' : 'Listing published to students.',
                  );
                },
                icon: Icon(o.published ? Icons.visibility_off_outlined : Icons.publish_rounded, size: 15),
                label: Text(o.published ? 'Unpublish' : 'Publish'),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.teal,
                  minimumSize: const Size(0, 34),
                  side: const BorderSide(color: AppColors.teal),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                onPressed: () {
                  AdminRepository.instance.setOpportunityVerified(o.id, !o.verified);
                  showAppSnackbar(context, o.verified ? 'Verification removed.' : 'Marked verified (demo).');
                },
                icon: const Icon(Icons.verified_outlined, size: 15),
                label: Text(o.verified ? 'Unverify' : 'Verify'),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFB45309),
                  minimumSize: const Size(0, 34),
                  side: const BorderSide(color: Color(0xFFB45309)),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().subtract(const Duration(days: 1)),
                    firstDate: DateTime(2020, 1, 1),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (picked != null && context.mounted) {
                    AdminRepository.instance.setOpportunityDeadline(o.id, picked);
                    showAppSnackbar(context, 'Deadline updated (listing shows as expired).');
                  }
                },
                icon: const Icon(Icons.event_busy_outlined, size: 15),
                label: const Text('Set past expiry'),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  minimumSize: const Size(0, 34),
                  side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                onPressed: () async {
                  final confirmed = await showAdminConfirm(
                    context,
                    title: 'Delete "${o.title}"?',
                    message: 'The listing is removed from the demo data entirely.',
                    confirmLabel: 'Delete',
                  );
                  if (confirmed && context.mounted) {
                    AdminRepository.instance.deleteOpportunity(o.id);
                    showAppSnackbar(context, 'Listing deleted.');
                  }
                },
                icon: const Icon(Icons.delete_outline_rounded, size: 15),
                label: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
