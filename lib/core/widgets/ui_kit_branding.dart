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
