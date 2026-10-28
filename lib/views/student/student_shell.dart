import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/responsive.dart';
import '../../core/widgets/ui_kit.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/notification_repository.dart';
import '../../viewmodels/chat_viewmodel.dart';
import '../../viewmodels/feed_viewmodel.dart';
import '../../viewmodels/library_viewmodel.dart';
import '../../viewmodels/opportunity_viewmodel.dart';
import 'profile/notifications_view.dart';
import 'profile/settings_view.dart';
import 'home/feed_view.dart';
import 'library/library_view.dart';
import 'chats/chats_view.dart';
import 'opportunities/opportunities_view.dart';
import 'profile/profile_view.dart';

/// Student application shell.
///
/// Mobile (<600px): bottom navigation + app bar.
/// Tablet/desktop (>=600px): persistent left sidebar + top bar with search,
/// notifications and profile controls. Content stays centred/max-width so
/// the mobile layout is never stretched across the screen.
class StudentShell extends StatefulWidget {
  const StudentShell({
    required this.feedViewModel,
    required this.libraryViewModel,
    required this.chatViewModel,
    required this.opportunityViewModel,
    super.key,
  });

  final FeedViewModel feedViewModel;
  final LibraryViewModel libraryViewModel;
  final ChatViewModel chatViewModel;
  final OpportunityViewModel opportunityViewModel;

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _index = 0;

  static const _titles = ['Home', 'Library', 'Chats', 'Explore', 'Profile'];

  void _goTo(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, type) {
        final useSidebar = type != ScreenType.mobile;

        final body = IndexedStack(
          index: _index,
          children: [
            FeedView(viewModel: widget.feedViewModel),
            LibraryView(viewModel: widget.libraryViewModel),
            ChatsView(viewModel: widget.chatViewModel),
            OpportunitiesView(viewModel: widget.opportunityViewModel),
            ProfileView(onOpenSettings: () => _push(const SettingsView())),
          ],
        );

        if (!useSidebar) {
          return Scaffold(
            appBar: AppBar(
              titleSpacing: 12,
              title: const AppLogo(size: 30, showText: true),
              actions: [
                _NotificationsButton(onOpen: () => _push(const NotificationsView())),
                _ProfileMenu(goTo: _goTo),
                const SizedBox(width: 8),
              ],
            ),
            body: body,
            bottomNavigationBar: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: _goTo,
              height: 66,
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
                NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book_rounded), label: 'Library'),
                NavigationDestination(icon: Icon(Icons.chat_bubble_outline_rounded), selectedIcon: Icon(Icons.chat_bubble_rounded), label: 'Chats'),
                NavigationDestination(icon: Icon(Icons.school_outlined), selectedIcon: Icon(Icons.school_rounded), label: 'Explore'),
                NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
              ],
            ),
          );
        }

        // Tablet / desktop: sidebar + top bar.
        return Scaffold(
          body: Row(
            children: [
              _Sidebar(index: _index, onSelect: _goTo),
              Expanded(
                child: Column(
                  children: [
                    _TopBar(
                      title: _titles[_index],
                      onSearch: (query) {
                        widget.libraryViewModel.setQuery(query);
                        _goTo(1);
                      },
                    ),
                    Expanded(child: body),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _push(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    const destinations = [
      (Icons.home_outlined, Icons.home_rounded, 'Home'),
      (Icons.menu_book_outlined, Icons.menu_book_rounded, 'Library'),
      (Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'Chats'),
      (Icons.school_outlined, Icons.school_rounded, 'Explore'),
      (Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
    ];

    return Container(
      width: 236,
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: AppLogo(size: 38),
          ),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 8),
          for (var i = 0; i < destinations.length; i++)
            _SidebarItem(
              icon: destinations[i].$1,
              activeIcon: destinations[i].$2,
              label: destinations[i].$3,
              selected: index == i,
              onTap: () => onSelect(i),
            ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(14),
            child: DemoBadge(label: 'PROTOTYPE'),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Material(
        color: selected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Icon(selected ? activeIcon : icon,
                    size: 21, color: selected ? AppColors.primary : AppColors.textSecondary),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.onSearch});

  final String title;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(width: 20),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: AppSearchField(
                  hint: 'Search resources…',
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) onSearch(value.trim());
                  },
                ),
              ),
            ),
          ),
          _NotificationsButton(onOpen: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsView()));
          }),
          const SizedBox(width: 4),
          _ProfileMenu(goTo: null),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _NotificationsButton extends StatelessWidget {
  const _NotificationsButton({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: NotificationRepository.instance,
      builder: (context, _) {
        final unread = NotificationRepository.instance.unreadCount;
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              tooltip: 'Notifications',
              onPressed: onOpen,
              icon: const Icon(Icons.notifications_outlined),
            ),
            if (unread > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                  child: Text('$unread',
                      style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  const _ProfileMenu({required this.goTo});

  /// When provided, switches tabs locally; otherwise pops to the shell.
  final void Function(int index)? goTo;

  @override
  Widget build(BuildContext context) {
    final me = AuthRepository.instance.currentUser;

    return PopupMenuButton<String>(
      tooltip: 'Account menu',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        switch (value) {
          case 'profile':
            if (goTo != null) {
              goTo!(4);
            } else {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileView()));
            }
          case 'settings':
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsView()));
          case 'signout':
            AuthRepository.instance.signOut();
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(me?.fullName ?? 'Student',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              Text(me?.institution.isEmpty ?? true ? 'Student' : me!.institution,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              if (me?.email != null && me!.email.isNotEmpty) ...[
                Text(me.email, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
              ],
            ],
          ),
        ),
        const PopupMenuItem(value: 'profile', child: Text('My profile')),
        const PopupMenuItem(value: 'settings', child: Text('Settings')),
        const PopupMenuItem(value: 'signout', child: Text('Sign out')),
      ],
      icon: AvatarCircle(name: me?.fullName ?? 'Student', radius: 16),
    );
  }
}
