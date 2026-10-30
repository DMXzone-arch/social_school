import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/ui_kit.dart';
import '../../../../models/enums.dart';
import '../../../../models/post.dart';
import '../../../../models/post_background.dart';
import '../../../../repositories/auth_repository.dart';
import '../../../../repositories/feed_repository.dart';
import 'comments_sheet.dart';
import 'post_menu.dart';

/// Facebook-style post card used by the home feed, search results and the
/// student profile.
///
/// Like / comment / share sit in an evenly-spaced action bar under a
/// top divider, Facebook-style. All actions go through [FeedRepository], so
/// the card works identically wherever it is embedded.
class PostCard extends StatelessWidget {
  const PostCard({required this.post, super.key});

  final Post post;

  /// Chosen colour background, when the post has one.
  PostBackground? get _background => PostBackground.byId(post.backgroundId);

  bool get _isMine =>
      post.authorId != null && post.authorId == AuthRepository.instance.currentUser?.id;

  @override
  Widget build(BuildContext context) {
    final isAnnouncement = post.isAnnouncement;
    final accent = post.type == PostType.adminAnnouncement
        ? AppColors.teal
        : isAnnouncement
            ? AppColors.gold
            : AppColors.primary;

    return SSCard(
      padding: EdgeInsets.zero,
      border: isAnnouncement ? Border.all(color: accent.withValues(alpha: 0.45)) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: avatar, bold name, "time · institution" subtitle -----
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 4, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AvatarCircle(
                  name: post.authorName,
                  radius: 20,
                  icon: isAnnouncement ? Icons.campaign_rounded : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              post.authorName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                            ),
                          ),
                          if (isAnnouncement) ...[
                            const SizedBox(width: 6),
                            Flexible(
                              child: StatusPill(text: postTypeLabel(post.type), color: accent),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.public_rounded,
                              size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${timeAgo(post.timestamp)} · ${post.authorInstitution}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ),
                          if (_isMine) ...[
                            const SizedBox(width: 6),
                            const StatusPill(text: 'Your post', color: AppColors.primary),
                          ],
                        ],
                      ),
                      if (post.taggedNames.isNotEmpty || post.location != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Row(
                            children: [
                              if (post.location != null) ...[
                                const Icon(Icons.location_on_rounded,
                                    size: 12, color: AppColors.teal),
                                const SizedBox(width: 3),
                              ],
                              Flexible(
                                child: Text(
                                  [
                                    if (post.taggedNames.isNotEmpty)
                                      'with ${post.taggedNames.map((n) => n.split(' ').first).join(', ')}',
                                    if (post.location != null) post.location!,
                                  ].join(' · '),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                PostMenuButton(post: post),
              ],
            ),
          ),

          // Body ---------------------------------------------------------
          Padding(
            padding: EdgeInsets.fromLTRB(14, _background == null ? 8 : 10, 14, 0),
            child: _background == null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (post.title != null) ...[
                        Text(post.title!,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                      ],
                      Text(post.content, style: const TextStyle(fontSize: 14.5, height: 1.5)),
                    ],
                  )
                : Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 180),
                    decoration: BoxDecoration(
                      gradient: _background!.gradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        post.content,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            height: 1.4,
                            color: Colors.white),
                      ),
                    ),
                  ),
          ),
          if (post.hasImage)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Container(
                height: 170,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accent.withValues(alpha: 0.25),
                      AppColors.teal.withValues(alpha: 0.25),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_rounded, color: AppColors.textSecondary),
                    SizedBox(height: 6),
                    Text('Photo attachment',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),

          // Comment count ------------------------------------------------
          if (post.comments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${post.comments.length} '
                    '${post.comments.length == 1 ? 'comment' : 'comments'}',
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

          // Action bar: Like / Comment / Share, evenly spaced ------------
          Divider(height: 1, color: AppColors.border),
          Row(
            children: [
              _ActionButton(
                icon: post.likedByMe
                    ? Icons.thumb_up_alt_rounded
                    : Icons.thumb_up_alt_outlined,
                label: post.likeCount > 0 ? '${post.likeCount}' : 'Like',
                active: post.likedByMe,
                onTap: () => FeedRepository.instance.toggleLike(post.id),
              ),
              _ActionButton(
                icon: Icons.mode_comment_outlined,
                label: 'Comment',
                onTap: () => showCommentsSheet(context, post),
              ),
              _ActionButton(
                icon: Icons.share_outlined,
                label: 'Share',
                onTap: () => showPostShareDialog(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One evenly-spaced action in the post's action bar (Like / Comment /
/// Share). Each occupies an equal third of the card width, Facebook-style.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.textSecondary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
