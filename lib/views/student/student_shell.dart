import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/responsive.dart';
import '../../core/widgets/ui_kit.dart';
import '../../viewmodels/chat_viewmodel.dart';
import '../../viewmodels/feed_viewmodel.dart';
import '../../viewmodels/library_viewmodel.dart';
import '../../viewmodels/opportunity_viewmodel.dart';
import 'profile/notifications_view.dart';
import 'profile/settings_view.dart';
import 'home/feed_view.dart';
import 'home/search_view.dart';
import 'library/library_view.dart';
import 'chats/chats_view.dart';
import 'opportunities/opportunities_view.dart';
import 'profile/profile_view.dart';
import 'shell/sidebar.dart';
import 'shell/top_bar_actions.dart';

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
              title: const Text(
                'Social School',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              actions: [
                IconButton(
                  tooltip: 'Search',
                  onPressed: () => _push(FeedSearchView(viewModel: widget.feedViewModel)),
                  icon: const Icon(Icons.search_rounded),
                ),
                NotificationsButton(onOpen: () => _push(const NotificationsView())),
                ProfileMenu(goTo: _goTo),
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
              StudentSidebar(index: _index, onSelect: _goTo),
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

/// Tablet/desktop top bar: page title, resource search, notifications bell
/// and the profile menu.
class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.onSearch});

  final String title;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
          NotificationsButton(onOpen: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsView()));
          }),
          const SizedBox(width: 4),
          ProfileMenu(goTo: null),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
