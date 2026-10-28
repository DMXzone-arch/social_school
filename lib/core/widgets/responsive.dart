import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

/// Layout size classes used across the prototype.
enum ScreenType { mobile, tablet, desktop }

/// Returns the current [ScreenType] from the available width.
ScreenType screenTypeOf(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < AppConstants.mobileBreakpoint) return ScreenType.mobile;
  if (width < AppConstants.desktopBreakpoint) return ScreenType.tablet;
  return ScreenType.desktop;
}

/// Rebuilds when the screen type changes.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({required this.builder, super.key});

  final Widget Function(BuildContext context, ScreenType type) builder;

  @override
  Widget build(BuildContext context) =>
      builder(context, screenTypeOf(context));
}

/// Centres content with a max width so desktop never stretches
/// the mobile layout across the whole screen.
class CenteredContent extends StatelessWidget {
  const CenteredContent({
    required this.child,
    this.maxWidth = AppConstants.contentMaxWidth,
    this.padding = const EdgeInsets.all(16),
    super.key,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
