import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/forms.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../core/widgets/responsive.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../models/enums.dart';
import '../../../repositories/auth_repository.dart';
import '../../../repositories/feed_repository.dart';
import '../../../repositories/library_repository.dart';
import '../../../repositories/opportunity_repository.dart';
import 'edit_profile_view.dart';
import 'my_posts_view.dart';
import 'saved_opportunities_view.dart';
import 'saved_resources_view.dart';
import 'settings_view.dart';

/// Student profile, styled after Facebook's profile page: a clean centred
/// header (avatar → name → details → Edit profile button) followed by
/// full-width action rows that lead to the pages holding the student's
/// content — My posts, Saved resources, Saved opportunities — plus Settings
/// and Sign out.
class ProfileView extends StatelessWidget {
  const ProfileView({this.onOpenSettings, super.key});

  /// Opens the settings page (provided by the shell tab); falls back to
  /// pushing [SettingsView] directly when the profile is opened full-screen.
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        AuthRepository.instance,
        FeedRepository.instance,
        LibraryRepository.instance,
        OpportunityRepository.instance,
      ]),
      builder: (context, _) {
        final me = AuthRepository.instance.currentUser;
        if (me == null) return const EmptyState(icon: Icons.person_off_outlined, title: 'Not signed in');

        final myPosts = FeedRepository.instance.posts
            .where((p) => p.authorId == me.id && !p.removedByAdmin)
            .length;
        final savedResources = LibraryRepository.instance.bookmarks.length;
        final savedOpportunities = OpportunityRepository.instance.saved.length;

        return CenteredContent(
          maxWidth: 760,
          child: ListView(
            children: [
              // Header: avatar, name and details centred like Facebook,
              // with the Edit profile button directly below the name.
              SSCard(
                child: Column(
                  children: [
                    ProfileAvatar(
                      name: me.fullName,
                      avatarIndex: me.avatarIndex,
                      hasPhoto: me.hasPhoto,
                      radius: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      me.fullName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${educationLevelLabel(me.educationLevel)} · '
                      '${me.institution.isEmpty ? 'Institution not set' : me.institution}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                    ),
                    if (me.bio.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        me.bio,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Center(
                      child: SizedBox(
                        width: 240,
                        child: AppButton(
                          label: 'Edit profile',
                          icon: Icons.edit_outlined,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const EditProfileView()),
                          ),
                        ),
                      ),
                    ),
                    if (me.interests.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text('Interests',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final interest in me.interests)
                            StatusPill(text: interest, color: AppColors.teal),
                        ],
                      ),
                    ],
                    if (!me.hasCompleteDetails) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF8A6100)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Some profile details are missing — tap Edit profile to complete them.',
                                style: TextStyle(fontSize: 12, color: Color(0xFF8A6100)),
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

              // Actions: each row leads to an existing page in the app.
              SSCard(
                child: Column(
                  children: [
                    _ProfileActionRow(
                      icon: Icons.forum_outlined,
                      label: 'My posts',
                      count: myPosts,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MyPostsView()),
                      ),
                    ),
                    const Divider(height: 1),
                    _ProfileActionRow(
                      icon: Icons.bookmark_border_rounded,
                      label: 'Saved resources',
                      count: savedResources,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SavedResourcesView()),
                      ),
                    ),
                    const Divider(height: 1),
                    _ProfileActionRow(
                      icon: Icons.school_outlined,
                      label: 'Saved opportunities',
                      count: savedOpportunities,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SavedOpportunitiesView()),
                      ),
                    ),
                    const Divider(height: 1),
                    _ProfileActionRow(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      onTap: () {
                        final openSettings = onOpenSettings;
                        if (openSettings != null) {
                          openSettings();
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SettingsView()),
                          );
                        }
                      },
                    ),
                    const Divider(height: 1),
                    _ProfileActionRow(
                      icon: Icons.logout_rounded,
                      label: 'Sign out',
                      danger: true,
                      onTap: () async {
                        final confirmed = await showConfirmDialog(
                          context,
                          title: 'Sign out?',
                          message: 'You have been signed out.',
                          confirmLabel: 'Sign out',
                        );
                        if (confirmed) AuthRepository.instance.signOut();
                      },
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

/// Full-width tappable action row: icon, label, optional count badge and a
/// chevron — the navigation pattern used by the profile's action list.
class _ProfileActionRow extends StatelessWidget {
  const _ProfileActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.count,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int? count;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: danger ? AppColors.error : AppColors.primary,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: danger ? AppColors.error : AppColors.textPrimary,
                ),
              ),
            ),
            if (count != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(Icons.chevron_right_rounded, size: 22, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
