import 'package:flutter/material.dart';

import '../../models/enums.dart';
import '../theme/app_theme.dart';
import 'forms.dart';
import 'profile_avatar.dart';

/// Opens the profile photo source sheet (camera/gallery/remove) and forwards
/// the resulting photo state to [onHasPhotoChanged].
///
/// Shared by profile setup and edit profile so both screens react to the
/// choice identically.
Future<void> pickProfilePhoto(
  BuildContext context, {
  required bool hasPhoto,
  required ValueChanged<bool> onHasPhotoChanged,
}) async {
  final choice = await showProfilePhotoSheet(context, hasPhoto: hasPhoto);
  if (!context.mounted) return;
  switch (choice) {
    case PhotoSheetChoice.camera:
    case PhotoSheetChoice.gallery:
      onHasPhotoChanged(true);
    case PhotoSheetChoice.remove:
      onHasPhotoChanged(false);
    case PhotoSheetChoice.cancel:
      break;
  }
}

/// Profile photo section shared by profile setup and edit profile: a large
/// preview avatar, vertically stacked photo actions (upload is primary) and,
/// when no photo is used, the avatar colour picker (Facebook-style default
/// avatar or a chosen colour behind a white person silhouette).
class ProfilePhotoField extends StatelessWidget {
  const ProfilePhotoField({
    required this.name,
    required this.hasPhoto,
    required this.avatarIndex,
    required this.onPickPhoto,
    required this.onUseDefaultAvatar,
    required this.onAvatarIndexChanged,
    this.radius = 38,
    super.key,
  });

  /// Name used for the initials-free placeholder rendering.
  final String name;

  final bool hasPhoto;
  final int avatarIndex;
  final double radius;

  /// Opens the photo source sheet (see [pickProfilePhoto]).
  final VoidCallback onPickPhoto;

  /// Switches back to the default (photo-less) avatar.
  final VoidCallback onUseDefaultAvatar;

  /// Reports the chosen avatar colour index (or [kDefaultAvatarIndex]).
  final ValueChanged<int> onAvatarIndexChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileAvatar(
          name: name,
          avatarIndex: avatarIndex,
          hasPhoto: hasPhoto,
          radius: radius,
        ),
        const SizedBox(height: 12),
        // Photo actions stacked vertically so the labels always fit.
        AppButton(
          label: hasPhoto ? 'Change photo' : 'Upload photo',
          icon: Icons.photo_camera_outlined,
          onPressed: onPickPhoto,
        ),
        const SizedBox(height: 10),
        AppOutlinedButton(
          label: 'Use default avatar',
          icon: Icons.person_outline,
          onPressed: onUseDefaultAvatar,
        ),
        if (!hasPhoto) ...[
          const SizedBox(height: 12),
          Text('Or pick an avatar colour',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              // Facebook-style default avatar (no colour).
              GestureDetector(
                onTap: () => onAvatarIndexChanged(kDefaultAvatarIndex),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.avatarPlaceholderBackground,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: avatarIndex == kDefaultAvatarIndex
                          ? AppColors.textPrimary
                          : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                  child: Icon(Icons.person,
                      size: 18, color: AppColors.avatarPlaceholderForeground),
                ),
              ),
              for (var i = 0; i < AppColors.avatarPalette.length; i++)
                GestureDetector(
                  onTap: () => onAvatarIndexChanged(i),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.avatarPalette[i],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: avatarIndex == i ? AppColors.textPrimary : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
