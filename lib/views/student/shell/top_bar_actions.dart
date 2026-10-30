import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../repositories/auth_repository.dart';
import '../../../repositories/notification_repository.dart';
import '../profile/profile_view.dart';
import '../profile/settings_view.dart';

/// Bell icon button with an unread badge, shared by the mobile app bar and the
/// desktop top bar. [onOpen] pushes the notifications screen.
class NotificationsButton extends StatelessWidget {
  const NotificationsButton({required this.onOpen, super.key});

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

/// Avatar popup menu with profile, settings and sign-out actions, shared by
/// the mobile app bar and the desktop top bar.
class ProfileMenu extends StatelessWidget {
  const ProfileMenu({required this.goTo, super.key});

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
              Text(me?.fullName ?? 'Member',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              Text(me?.institution.isEmpty ?? true ? 'Member' : me!.institution,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              if (me?.email != null && me!.email.isNotEmpty) ...[
                Text(me.email, style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
              ],
            ],
          ),
        ),
        const PopupMenuItem(value: 'profile', child: Text('My profile')),
        const PopupMenuItem(value: 'settings', child: Text('Settings')),
        const PopupMenuItem(value: 'signout', child: Text('Sign out')),
      ],
      icon: AvatarCircle(name: me?.fullName ?? 'Member', radius: 16),
    );
  }
}
