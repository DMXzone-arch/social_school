import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../repositories/auth_repository.dart';
import '../../../repositories/chat_repository.dart';
import '../../../models/conversation.dart';
import 'edit_profile_view.dart';

/// Student settings — every action here is simulated in the prototype.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthRepository.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListenableBuilder(
        listenable: Listenable.merge([auth, ChatRepository.instance]),
        builder: (context, _) {
          final me = auth.currentUser;
          final blocked = ChatRepository.instance.blocked;

          return CenteredContent(
            maxWidth: 680,
            child: ListView(
              children: [
                _Section(title: 'Account', children: [
                  _ActionTile(
                    icon: Icons.edit_outlined,
                    title: 'Edit profile',
                    subtitle: 'Name, institution, interests and avatar',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EditProfileView()),
                    ),
                  ),
                  _ActionTile(
                    icon: Icons.lock_outline_rounded,
                    title: 'Change password',
                    subtitle: 'Update your password',
                    onTap: () => _demoDialog(
                      context,
                      title: 'Change password',
                      message: 'Enter a new password to update your account. '
                          'Your password will be updated securely.',
                    ),
                  ),
                  _SwitchTile(
                    icon: Icons.visibility_outlined,
                    title: 'Profile visibility',
                    subtitle: 'Let other students find your profile',
                    value: me?.profileVisible ?? true,
                    onChanged: auth.setProfileVisibility,
                  ),
                ]),
                _Section(title: 'Notifications', children: [
                  for (final entry in auth.notificationPrefs.entries.toList())
                    _SwitchTile(
                      icon: Icons.notifications_none_rounded,
                      title: entry.key,
                      subtitle: 'Push and email notifications',
                      value: entry.value,
                      onChanged: (v) => auth.setNotificationPref(entry.key, v),
                    ),
                ]),
                _Section(title: 'Privacy & safety', children: [
                  _ActionTile(
                    icon: Icons.block_outlined,
                    title: 'Blocked users',
                    subtitle: blocked.isEmpty
                        ? 'No blocked accounts'
                        : '${blocked.length} blocked',
                    onTap: () => _showBlockedDialog(context, blocked),
                  ),
                  _ActionTile(
                    icon: Icons.description_outlined,
                    title: 'Terms of Use',
                    onTap: () => _demoDialog(
                      context,
                      title: 'Terms of Use',
                      message: 'These are the terms of use for Social School. '
                          'By using the app you agree to these terms.',
                    ),
                  ),
                  _ActionTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () => _demoDialog(
                      context,
                      title: 'Privacy Policy',
                      message: 'Social School respects your privacy. We '
                          'only collect the data needed to run your account.',
                    ),
                  ),
                ]),
                _Section(title: 'Support', children: [
                  _ActionTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Help and support',
                    subtitle: 'FAQ and contact',
                    onTap: () => _demoDialog(
                      context,
                      title: 'Help & support',
                      message: 'Browse frequently asked questions or '
                          'contact the support team for help.',
                    ),
                  ),
                ]),
                _Section(title: 'Danger zone', children: [
                  _ActionTile(
                    icon: Icons.delete_forever_outlined,
                    title: 'Delete account',
                    subtitle: 'Delete your account and data',
                    danger: true,
                    onTap: () async {
                      final confirmed = await showConfirmDialog(
                        context,
                        title: 'Delete account?',
                        message: 'This will permanently delete your account and '
                            'all associated data. This cannot be undone.',
                        confirmLabel: 'Delete account',
                      );
                      if (confirmed && context.mounted) {
                        showAppSnackbar(context, 'Your account has been deleted.');
                      }
                    },
                  ),
                  _ActionTile(
                    icon: Icons.logout_rounded,
                    title: 'Sign out',
                    danger: true,
                    onTap: () async {
                      final confirmed = await showConfirmDialog(
                        context,
                        title: 'Sign out?',
                        message: 'You have been signed out.',
                        confirmLabel: 'Sign out',
                        danger: false,
                      );
                      if (confirmed) AuthRepository.instance.signOut();
                    },
                  ),
                ]),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      '${AppConstants.appName} · Version 1.0',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  void _demoDialog(BuildContext context, {required String title, required String message}) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: Text(message, style: const TextStyle(height: 1.5)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  void _showBlockedDialog(BuildContext context, List<Conversation> blocked) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Blocked users'),
        content: SizedBox(
          width: 380,
          height: 260,
          child: blocked.isEmpty
              ? const EmptyState(
                  icon: Icons.block_rounded,
                  title: 'No blocked accounts',
                  message: 'Accounts you block from a conversation appear here.',
                )
              : ListView(
                  children: [
                    for (final conversation in blocked)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: AvatarCircle(name: conversation.peerName, radius: 18),
                        title: Text(conversation.peerName),
                        trailing: TextButton(
                          onPressed: () {
                            ChatRepository.instance.unblock(conversation.id);
                            showAppSnackbar(context, '${conversation.peerName} unblocked.');
                          },
                          child: const Text('Unblock'),
                        ),
                      ),
                  ],
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 14, 0, 8),
          child: Text(title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
        ),
        SSCard(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.error : AppColors.textPrimary;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, size: 20, color: danger ? AppColors.error : AppColors.textSecondary),
      title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      secondary: Icon(icon, size: 20, color: AppColors.textSecondary),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
    );
  }
}
