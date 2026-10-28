import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../models/admin.dart';
import '../../../models/enums.dart';
import '../../../repositories/admin_repository.dart';
import 'admin_shell.dart';

/// Admin institution management (fictional demo institutions).
class InstitutionsView extends StatefulWidget {
  const InstitutionsView({super.key});

  @override
  State<InstitutionsView> createState() => _InstitutionsViewState();
}

class _InstitutionsViewState extends State<InstitutionsView> {
  String _query = '';
  InstitutionType? _type;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminRepository.instance,
      builder: (context, _) {
        final institutions = AdminRepository.instance.institutions.where((i) {
          final matchesType = _type == null || i.type == _type;
          final matchesQuery = _query.isEmpty ||
              i.name.toLowerCase().contains(_query.toLowerCase()) ||
              i.location.toLowerCase().contains(_query.toLowerCase());
          return matchesType && matchesQuery;
        }).toList();

        return CenteredContent(
          maxWidth: 1100,
          child: ListView(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Institutions',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.teal),
                    onPressed: _showAddDialog,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add institution'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Fictional demo institutions used for profiles, communities and resources.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              AppSearchField(
                  hint: 'Search by name or location…',
                  onChanged: (v) => setState(() => _query = v)),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    appFilterChip('All', selected: _type == null,
                        onTap: () => setState(() => _type = null)),
                    for (final type in InstitutionType.values) ...[
                      const SizedBox(width: 8),
                      appFilterChip(institutionTypeLabel(type),
                          selected: _type == type, onTap: () => setState(() => _type = type)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (institutions.isEmpty)
                const EmptyState(
                  icon: Icons.apartment_outlined,
                  title: 'No institutions match',
                  message: 'Add a fictional institution or clear the filters.',
                )
              else
                ResponsiveBuilder(
                  builder: (context, type) =>
                      type == ScreenType.desktop ? _table(institutions) : _cards(institutions),
                ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _table(List<Institution> institutions) {
    return SSCard(
      padding: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 24,
          headingTextStyle: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Location')),
            DataColumn(label: Text('Programmes')),
            DataColumn(label: Text('Actions')),
          ],
          rows: [
            for (final institution in institutions)
              DataRow(cells: [
                DataCell(Text(institution.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                DataCell(Text(institutionTypeLabel(institution.type),
                    style: const TextStyle(fontSize: 12.5))),
                DataCell(Text(institution.location, style: const TextStyle(fontSize: 12.5))),
                DataCell(SizedBox(
                  width: 260,
                  child: Text(
                    institution.programmes.isEmpty ? '—' : institution.programmes.join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                )),
                DataCell(_RemoveButton(institution: institution)),
              ]),
          ],
        ),
      ),
    );
  }

  Widget _cards(List<Institution> institutions) {
    return Column(
      children: [
        for (final institution in institutions) ...[
          SSCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.apartment_rounded, size: 20, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(institution.name,
                          style:
                              const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    ),
                    StatusPill(
                        text: institutionTypeLabel(institution.type), color: AppColors.primary),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${institution.location} · '
                  '${institution.programmes.isEmpty ? 'no programmes listed' : institution.programmes.join(', ')}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: _RemoveButton(institution: institution),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  void _showAddDialog() {
    final name = TextEditingController();
    final location = TextEditingController();
    final programmes = TextEditingController();
    var type = InstitutionType.secondary;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add institution'),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(
                      labelText: 'Institution name (fictional)',
                      hintText: 'e.g. Kambiri University',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<InstitutionType>(
                  initialValue: type,
                  decoration: const InputDecoration(
                      labelText: 'Type', border: OutlineInputBorder(), isDense: true),
                  items: [
                    for (final t in InstitutionType.values)
                      DropdownMenuItem(value: t, child: Text(institutionTypeLabel(t))),
                  ],
                  onChanged: (v) => setState(() => type = v ?? type),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: location,
                  decoration: const InputDecoration(
                      labelText: 'Location', hintText: 'e.g. Mzuzu (demo)',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: programmes,
                  decoration: const InputDecoration(
                      labelText: 'Programmes (comma separated)',
                      hintText: 'e.g. BSc Nursing, BEd',
                      border: OutlineInputBorder()),
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
                if (name.text.trim().isEmpty) {
                  showAppSnackbar(context, 'Institution name is required.', error: true);
                  return;
                }
                Navigator.pop(dialogContext);
                AdminRepository.instance.addInstitution(
                  name.text.trim(),
                  type,
                  location.text.trim().isEmpty ? 'Malawi (demo)' : location.text.trim(),
                  programmes.text
                      .split(',')
                      .map((p) => p.trim())
                      .where((p) => p.isNotEmpty)
                      .toList(),
                );
                showAppSnackbar(context, 'Institution added to the demo data.');
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.institution});

  final Institution institution;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.error,
        side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
        minimumSize: const Size(0, 32),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
      onPressed: () async {
        final confirmed = await showAdminConfirm(
          context,
          title: 'Remove "${institution.name}"?',
          message: 'The institution is removed from the demo data.',
          confirmLabel: 'Remove',
        );
        if (!confirmed || !context.mounted) return;
        AdminRepository.instance.removeInstitution(institution.id);
        showAppSnackbar(context, 'Institution removed.');
      },
      icon: const Icon(Icons.delete_outline_rounded, size: 15),
      label: const Text('Remove'),
    );
  }
}
