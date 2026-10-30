import 'package:flutter/material.dart';

/// Named colour background for text-only posts, Facebook-style.
///
/// FUTURE BACKEND INTEGRATION POINT (Supabase): posts store the chosen
/// background as a `background_id` text column; this catalogue stays
/// client-side so ids render the same gradient everywhere.
class PostBackground {
  const PostBackground(this.id, this.name, this.colors);

  final String id;
  final String name;
  final List<Color> colors;

  Gradient get gradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      );

  /// Looks up a background by id; `null`/unknown ids return `null` (plain post).
  static PostBackground? byId(String? id) {
    if (id == null) return null;
    for (final background in all) {
      if (background.id == id) return background;
    }
    return null;
  }

  static const List<PostBackground> all = [
    PostBackground('ocean', 'Ocean', [Color(0xFF1769AA), Color(0xFF38BDF8)]),
    PostBackground('sunset', 'Sunset', [Color(0xFFB45309), Color(0xFFF4B942)]),
    PostBackground('forest', 'Forest', [Color(0xFF15803D), Color(0xFF16A085)]),
    PostBackground('berry', 'Berry', [Color(0xFFBE185D), Color(0xFF7C3AED)]),
    PostBackground('grape', 'Grape', [Color(0xFF6D28D9), Color(0xFF1769AA)]),
    PostBackground('midnight', 'Midnight', [Color(0xFF1F2937), Color(0xFF475569)]),
    PostBackground('gold', 'Gold', [Color(0xFFF4B942), Color(0xFFDC2626)]),
    PostBackground('teal', 'Teal', [Color(0xFF16A085), Color(0xFF1769AA)]),
  ];
}
