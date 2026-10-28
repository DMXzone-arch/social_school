import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/responsive.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../models/admin.dart';
import '../../../models/enums.dart';
import '../../../repositories/admin_repository.dart';
import 'admin_shell.dart';

/// Admin user management with fictional demo accounts only.
class UsersView extends StatefulWidget {
  const UsersView({super.key});

  @override
  State<UsersView> createState() => _UsersViewState();
}

class _UsersViewState extends State<UsersView> {
  String _query = '';
  AccountStatus? _status;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminRepository.instance,
      builder: (context, _) {
        final users = AdminRepository.instance.users.where((user) {
          final matchesStatus = _status == null || user.status == _status;
          final matchesQuery = _query.isEmpty ||
              user.fullName.toLowerCase().contains(_query.toLowerCase()) ||
              user.email.toLowerCase().contains(_query.toLowerCase()) ||
              user.institution.toLowerCase().contains(_query.toLowerCase());
          return matchesStatus && matchesQuery;
        }).toList();

        return CenteredContent(
          maxWidth: 1150,
          child: ListView(
            children: [
              const Text('User Management',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text(
                'Fictional demo accounts only — suspending or restoring is simulated '
                'and affects no real users.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              AppSearchField(hint: 'Search by name, email or institution…',
                  onChanged: (v) => setState(() => _query = v)),
              const SizedBox(height: 12),
              Row(
                children: [
                  appFilterChip('All', selected: _status == null,
                      onTap: () => setState(() => _status = null)),
                  const SizedBox(width: 8),
                  appFilterChip('Active', selected: _status == AccountStatus.active,
                      onTap: () => setState(() => _status = AccountStatus.active)),
                  const SizedBox(width: 8),
                  appFilterChip('Suspended', selected: _status == AccountStatus.suspended,
                      onTap: () => setState(() => _status = AccountStatus.suspended)),
                ],
              ),
              const SizedBox(height: 14),
              if (users.isEmpty)
                const EmptyState(
                  icon: Icons.people_alt_outlined,
                  title: 'No accounts match',
                  message: 'Try clearing the search or status filter.',
                )
              else
                ResponsiveBuilder(
                  builder: (context, type) =>
                      type == ScreenType.desktop ? _table(users) : _cards(users),
                ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _table(List<DemoStudentAccount> users) {
    return SSCard(
      padding: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 24,
          headingTextStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Email (placeholder)')),
            DataColumn(label: Text('Level')),
            DataColumn(label: Text('Institution')),
            DataColumn(label: Text('Registered')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: [
            for (final user in users)
              DataRow(
                cells: [
                  DataCell(Text(user.fullName,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                  DataCell(Text(user.email, style: const TextStyle(fontSize: 12.5))),
                  DataCell(Text(educationLevelLabel(user.level),
                      style: const TextStyle(fontSize: 12.5))),
                  DataCell(SizedBox(
                      width: 200,
                      child: Text(user.institution,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12.5)))),
                  DataCell(Text(formatDate(user.registered),
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary))),
                  DataCell(StatusPill(
                    text: accountStatusLabel(user.status),
                    color: user.status == AccountStatus.active ? AppColors.success : AppColors.error,
                  )),
                  DataCell(_UserAction(user: user)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _cards(List<DemoStudentAccount> users) {
    return Column(
      children: [
        for (final user in users) ...[
          SSCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AvatarCircle(name: user.fullName, radius: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.fullName,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          Text(user.email,
                              style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    StatusPill(
                      text: accountStatusLabel(user.status),
                      color: user.status == AccountStatus.active ? AppColors.success : AppColors.error,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${educationLevelLabel(user.level)} · ${user.institution} · '
                  'joined ${formatDate(user.registered)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: _UserAction(user: user),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _UserAction extends StatelessWidget {
  const _UserAction({required this.user});

  final DemoStudentAccount user;

  @override
  Widget build(BuildContext context) {
    final suspended = user.status == AccountStatus.suspended;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: suspended ? AppColors.success : AppColors.error,
        side: BorderSide(color: suspended ? AppColors.success : AppColors.error.withValues(alpha: 0.5)),
        minimumSize: const Size(0, 32),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
      onPressed: () async {
        final confirmed = await showAdminConfirm(
          context,
          title: suspended ? 'Restore ${user.fullName}?' : 'Suspend ${user.fullName}?',
          message: suspended
              ? 'The demo account becomes active again.'
              : 'The demo account is marked suspended (simulated — no real account exists).',
          confirmLabel: suspended ? 'Restore' : 'Suspend',
          danger: !suspended,
        );
        if (!confirmed || !context.mounted) return;
        suspended
            ? AdminRepository.instance.restoreUser(user.id)
            : AdminRepository.instance.suspendUser(user.id);
        showAppSnackbar(
          context,
          suspended ? 'Account restored (simulated).' : 'Account suspended (simulated).',
        );
      },
      child: Text(suspended ? 'Restore' : 'Suspend'),
    );
  }
}
