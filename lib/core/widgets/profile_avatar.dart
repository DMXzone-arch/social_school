import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_theme.dart';
import '../../models/enums.dart';

/// Outcome of the mock "choose a profile photo" bottom sheet.
enum PhotoSheetChoice { camera, gallery, remove, cancel }

/// A student's profile picture.
///
/// * [hasPhoto] true → uploaded profile photo (mocked as a soft gradient
///   placeholder with a person silhouette).
/// * [hasPhoto] false and [kDefaultAvatarIndex] → the Facebook-style default
///   avatar: light grey circle with a darker grey person silhouette.
/// * [hasPhoto] false and a colour chosen → the chosen colour fills the circle
///   **behind a white person silhouette** (never initials or a placeholder
///   character).
///
/// FUTURE Supabase/R2 integration: when a real backend exists, replace the
/// gradient placeholder with `CircleAvatar(backgroundImage: NetworkImage(...))`
/// pointing at the image stored in Cloudflare R2, with the public URL kept on
/// [StudentProfile].
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    required this.name,
    this.avatarIndex = kDefaultAvatarIndex,
    this.hasPhoto = false,
    this.radius = 22,
    this.icon,
    super.key,
  });

  final String name;
  final int avatarIndex;
  final bool hasPhoto;
  final double radius;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (hasPhoto) {
      final seed = name.isEmpty ? avatarIndex : name.hashCode.abs();
      final palette = AppColors.avatarPalette;
      final from = palette[seed % palette.length];
      final to = palette[(seed ~/ 7 + 3) % palette.length];
      return Container(
        width: radius * 2,
        height: radius * 2,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [from, to],
          ),
        ),
        child: Icon(
          icon ?? Icons.person_rounded,
          color: Colors.white.withValues(alpha: 0.95),
          size: radius * 1.15,
        ),
      );
    }

    // Facebook-style default avatar when no photo and no colour was chosen.
    if (avatarIndex < 0) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.avatarPlaceholderBackground,
        child: Icon(
          icon ?? Icons.person,
          size: radius * 1.2,
          color: AppColors.avatarPlaceholderForeground,
        ),
      );
    }

    // Chosen colour fills the circle; a white person silhouette sits on top
    // (same style as Facebook's coloured avatars — never initials or "?").
    final color = AppColors.avatarPalette[avatarIndex % AppColors.avatarPalette.length];
    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: Icon(
        icon ?? Icons.person,
        color: Colors.white,
        size: radius * 1.2,
      ),
    );
  }
}

/// Shows the mock "choose a profile photo" sheet and returns the user's choice.
///
/// FUTURE Supabase/R2 integration: "camera"/"gallery" would launch the real
/// image picker, upload the file to Cloudflare R2, and store the returned URL.
Future<PhotoSheetChoice> showProfilePhotoSheet(
  BuildContext context, {
  required bool hasPhoto,
}) async {
  final choice = await showModalBottomSheet<PhotoSheetChoice>(
    context: context,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 14),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Profile picture',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 6),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined, color: AppColors.primary),
            title: const Text('Take a photo'),
            onTap: () => Navigator.pop(ctx, PhotoSheetChoice.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
            title: const Text('Choose from gallery'),
            onTap: () => Navigator.pop(ctx, PhotoSheetChoice.gallery),
          ),
          if (hasPhoto)
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
              title: const Text('Remove current photo'),
              onTap: () => Navigator.pop(ctx, PhotoSheetChoice.remove),
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  return choice ?? PhotoSheetChoice.cancel;
}
