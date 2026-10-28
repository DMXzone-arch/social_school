import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive.dart';
import '../../../repositories/admin_repository.dart';
import 'audit_log_view.dart';
import 'dashboard_view.dart';
import 'feed_management_view.dart';
import 'institutions_view.dart';
import 'opportunities_management_view.dart';
import 'reports_view.dart';
import 'resources_view.dart';
import 'storage_view.dart';
import 'users_view.dart';

/// Admin application shell: persistent sidebar on desktop, collapsible
/// drawer on mobile. Clearly separated from the student app and always
/// showing the ADMIN label.
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  static const _sections = [
    (Icons.dashboard_outlined, Icons.dashboard_rounded, 'Dashboard'),
    (Icons.inventory_2_outlined, Icons.inventory_2_rounded, 'Resource Management'),
    (Icons.campaign_outlined, Icons.campaign_rounded, 'Feed Management'),
    (Icons.school_outlined, Icons.school_rounded, 'Opportunities'),
    (Icons.people_alt_outlined, Icons.people_alt_rounded, 'User Management'),
    (Icons.flag_outlined, Icons.flag_rounded, 'Reports & Moderation'),
    (Icons.apartment_outlined, Icons.apartment_rounded, 'Institutions'),
    (Icons.storage_outlined, Icons.storage_rounded, 'Storage & Settings'),
    (Icons.history_rounded, Icons.history_rounded, 'Audit Log'),
  ];

  void _select(int index) {
    setState(() => _index = index);
    Navigator.of(context).maybePop(); // close mobile drawer if open.
  }

  Future<void> _signOut() async {
    final confirmed = await showAdminConfirm(
      context,
      title: 'Sign out of the Admin Portal?',
      message: 'You will return to the admin sign-in screen (demo).',
      confirmLabel: 'Sign out',
    );
    if (!confirmed) return;
    AdminRepository.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, type) {
        final body = IndexedStack(index: _index, children: _pages());

        if (type == ScreenType.mobile) {
          return Scaffold(
            appBar: AppBar(
              leading: Builder(
                builder: (context) => IconButton(
                  tooltip: 'Admin menu',
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu_rounded),
                ),
              ),
              title: Row(
                children: [
                  Text(_sections[_index].$3,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(width: 10),
                  const AdminBadge(),
                ],
              ),
            ),
            drawer: Drawer(
              child: _SidebarContent(
                index: _index,
                onSelect: _select,
                sections: _sections,
                onSignOut: _signOut,
              ),
            ),
            body: body,
          );
        }

        return Scaffold(
          body: Row(
            children: [
              SizedBox(
                width: 250,
                child: _SidebarContent(
                  index: _index,
                  onSelect: _select,
                  sections: _sections,
                  onSignOut: _signOut,
                ),
              ),
              const VerticalDivider(width: 1, color: AppColors.border),
              Expanded(child: body),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _pages() => const [
        DashboardView(),
        ResourcesView(),
        FeedManagementView(),
        OpportunitiesManagementView(),
        UsersView(),
        ReportsView(),
        InstitutionsView(),
        StorageView(),
        AuditLogView(),
      ];
}

/// Teal ADMIN label used across the admin area and the admin entry in menus.
class AdminBadge extends StatelessWidget {
  const AdminBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.teal,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'ADMIN',
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _SidebarContent extends StatelessWidget {
  const _SidebarContent({
    required this.index,
    required this.onSelect,
    required this.sections,
    required this.onSignOut,
  });

  final int index;
  final ValueChanged<int> onSelect;
  final List<(IconData, IconData, String)> sections;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 30),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Social School',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text('ADMIN',
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1,
                                    color: AppColors.teal)),
                          ),
                          const SizedBox(width: 6),
                          const Flexible(
                            child: Text('Management Portal',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.white70, fontSize: 10.5)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < sections.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
            child: Material(
              color: index == i ? AppColors.teal.withValues(alpha: 0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () => onSelect(i),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Icon(
                        index == i ? sections[i].$2 : sections[i].$1,
                        size: 19,
                        color: index == i ? AppColors.teal : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          sections[i].$3,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: index == i ? FontWeight.w700 : FontWeight.w500,
                            color: index == i ? AppColors.teal : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(10),
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: onSignOut,
            icon: const Icon(Icons.logout_rounded, size: 17),
            label: const Text('Sign Out'),
          ),
        ),
      ],
    );
  }
}

/// Confirmation dialog used across the admin screens.
Future<bool> showAdminConfirm(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  bool danger = true,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
      content: Text(message, style: const TextStyle(color: AppColors.textSecondary, height: 1.4)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: danger ? AppColors.error : AppColors.teal),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
