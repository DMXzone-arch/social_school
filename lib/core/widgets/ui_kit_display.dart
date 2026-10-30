import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
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
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: border ?? Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.isDark ? const Color(0x66000000) : const Color(0x0D1F2937),
            blurRadius: 14,
            offset: const Offset(0, 4),
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
                Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
