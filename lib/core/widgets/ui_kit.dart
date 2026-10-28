import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_theme.dart';

/// Social School logo — graduation cap + name.
/// TODO(branding): replace the cap container with the official brand asset.
class AppLogo extends StatelessWidget {
  const AppLogo({this.size = 44, this.showText = true, this.lightText = false, super.key});

  final double size;
  final bool showText;
  final bool lightText;

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(Icons.school_rounded, color: Colors.white, size: size * 0.6),
    );

    if (!showText) return mark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(width: size * 0.3),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppConstants.appName,
                style: TextStyle(
                  fontSize: size * 0.42,
                  fontWeight: FontWeight.w800,
                  color: lightText ? Colors.white : AppColors.textPrimary,
                ),
              ),
              Text(
                AppConstants.tagline,
                style: TextStyle(
                  fontSize: size * 0.24,
                  color: lightText ? Colors.white70 : AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Deprecated: demo/prototype markers have been removed for a production
/// look. Kept as a no-op so existing call sites still compile.
class DemoBadge extends StatelessWidget {
  const DemoBadge({this.label = 'DEMO DATA', super.key});

  final String label;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// Small coloured pill for statuses (Approved, Pending, Expired...).
class StatusPill extends StatelessWidget {
  const StatusPill({required this.text, required this.color, super.key});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

/// Section title with optional trailing action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({required this.title, this.trailing, super.key});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Rounded white card with subtle shadow — the standard surface.
class SSCard extends StatelessWidget {
  const SSCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
    this.border,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    // The coloured box wraps the Material (not the other way around) so that
    // ListTiles and InkWells inside the card paint their ink ON TOP of the
    // white background. This also silences the framework's "ListTile background
    // color or ink splashes may be invisible" warning, which fires when a
    // coloured box sits between a ListTile and its Material ancestor.
    return Container(
      decoration: BoxDecoration(
        color: color ?? AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: border ?? Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D1F2937),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Facebook-style placeholder avatar: light grey circle with a darker grey
/// person silhouette, used when a user has no profile photo.
class DefaultAvatar extends StatelessWidget {
  const DefaultAvatar({this.radius = 22, super.key});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.avatarPlaceholderBackground,
      child: Icon(
        Icons.person,
        size: radius * 1.2,
        color: AppColors.avatarPlaceholderForeground,
      ),
    );
  }
}

/// Initials avatar with a deterministic colour per name.
///
/// Falls back to the Facebook-style [DefaultAvatar] when [name] is empty
/// (no initials to show).
class AvatarCircle extends StatelessWidget {
  const AvatarCircle({required this.name, this.radius = 22, this.icon, super.key});

  final String name;
  final double radius;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (name.trim().isEmpty) {
      return DefaultAvatar(radius: radius);
    }
    final initials = _initialsOf(name);
    final color = AppColors.avatarPalette[name.hashCode.abs() % AppColors.avatarPalette.length];
    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: icon != null
          ? Icon(icon, color: Colors.white, size: radius)
          : Text(
              initials,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: radius * 0.8,
              ),
            ),
    );
  }

  static String _initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts[1].characters.first).toUpperCase();
  }
}

/// Label + value row with an icon, used in detail screens.
class InfoRow extends StatelessWidget {
  const InfoRow({required this.icon, required this.label, required this.value, super.key});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Search field used across feed, library, chats and admin.
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    this.controller,
    this.hint = 'Search…',
    this.onChanged,
    this.onSubmitted,
    super.key,
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
      ),
    );
  }
}

/// Standard filter/choice chip.
Widget appFilterChip(
  String label, {
  required bool selected,
  VoidCallback? onTap,
  IconData? icon,
}) {
  return ChoiceChip(
    label: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 15, color: selected ? Colors.white : AppColors.textSecondary),
          const SizedBox(width: 5),
        ],
        Text(label),
      ],
    ),
    selected: selected,
    showCheckmark: false,
    onSelected: onTap == null ? null : (_) => onTap(),
    selectedColor: AppColors.primary,
    backgroundColor: AppColors.white,
    side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
    labelStyle: TextStyle(
      fontSize: 13,
      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      color: selected ? Colors.white : AppColors.textSecondary,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
  );
}

/// Floating snackbar helper.
void showAppSnackbar(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? AppColors.error : AppColors.textPrimary,
      ),
    );
}

/// Confirmation dialog for destructive/simulated actions.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool danger = true,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      content: Text(message, style: const TextStyle(color: AppColors.textSecondary)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel, style: const TextStyle(color: AppColors.textSecondary)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: danger ? AppColors.error : AppColors.primary,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
