import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/responsive.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../repositories/auth_repository.dart';
import '../../../repositories/chat_repository.dart';
import '../../../models/conversation.dart';
import 'edit_profile_view.dart';
import 'widgets/settings_tiles.dart';

/// Student settings — every action here is simulated in the prototype.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthRepository.instance;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          auth,
          ChatRepository.instance,
          ThemeController.instance,
        ]),
        builder: (context, _) {
          final me = auth.currentUser;
          final blocked = ChatRepository.instance.blocked;

          return CenteredContent(
            maxWidth: 680,
            child: ListView(
              children: [
                SettingsSection(title: 'Account', children: [
                  SettingsActionTile(
                    icon: Icons.edit_outlined,
                    title: 'Edit profile',
                    subtitle: 'Name, institution, interests and avatar',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EditProfileView()),
                    ),
                  ),
                  SettingsActionTile(
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
                  SettingsSwitchTile(
                    icon: Icons.visibility_outlined,
                    title: 'Profile visibility',
                    subtitle: 'Let other members find your profile',
                    value: me?.profileVisible ?? true,
                    onChanged: auth.setProfileVisibility,
                  ),
                ]),
                SettingsSection(title: 'Appearance', children: [
                  SettingsSwitchTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark mode',
                    subtitle: 'Easier on the eyes in low light',
                    value: ThemeController.instance
                        .isDarkFor(ThemeController.platformBrightness),
                    onChanged: ThemeController.instance.setDark,
                  ),
                ]),
                SettingsSection(title: 'Notifications', children: [
                  for (final entry in auth.notificationPrefs.entries.toList())
                    SettingsSwitchTile(
                      icon: Icons.notifications_none_rounded,
                      title: entry.key,
                      subtitle: 'Push and email notifications',
                      value: entry.value,
                      onChanged: (v) => auth.setNotificationPref(entry.key, v),
                    ),
                ]),
                SettingsSection(title: 'Privacy & safety', children: [
                  SettingsActionTile(
                    icon: Icons.block_outlined,
                    title: 'Blocked users',
                    subtitle: blocked.isEmpty
                        ? 'No blocked accounts'
                        : '${blocked.length} blocked',
                    onTap: () => _showBlockedDialog(context, blocked),
                  ),
                  SettingsActionTile(
                    icon: Icons.description_outlined,
                    title: 'Terms of Use',
                    onTap: () => _demoDialog(
                      context,
                      title: 'Terms of Use',
                      message: 'These are the terms of use for Social School. '
                          'By using the app you agree to these terms.',
                    ),
                  ),
                  SettingsActionTile(
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
                SettingsSection(title: 'Support', children: [
                  SettingsActionTile(
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
                SettingsSection(title: 'Danger zone', children: [
                  SettingsActionTile(
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
                  SettingsActionTile(
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
                Padding(
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
