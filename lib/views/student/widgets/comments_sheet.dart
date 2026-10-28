import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/states.dart';
import '../../../../core/widgets/ui_kit.dart';
import '../../../../models/post.dart';
import '../../../../repositories/auth_repository.dart';
import '../../../../repositories/feed_repository.dart';

/// Reusable bottom sheet listing a post's comments with an input to add one.
Future<void> showCommentsSheet(BuildContext context, Post post) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: _CommentsSheet(postId: post.id),
    ),
  );
}

class _CommentsSheet extends StatefulWidget {
  const _CommentsSheet({required this.postId});

  final String postId;

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final TextEditingController _controller = TextEditingController();

  Post? get _post => FeedRepository.instance.byId(widget.postId);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final me = AuthRepository.instance.currentUser;
    if (me == null) return;
    FeedRepository.instance.addComment(widget.postId, me, text);
    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        final post = _post;
        if (post == null) return const SizedBox.shrink();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Comments',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                  Text('${post.comments.length}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: post.comments.isEmpty
                  ? const EmptyState(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'No comments yet',
                      message: 'Be the first to reply to this post.',
                    )
                  : ListenableBuilder(
                      listenable: FeedRepository.instance,
                      builder: (context, _) => ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: post.comments.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final comment = post.comments[index];
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AvatarCircle(name: comment.authorName, radius: 16),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(comment.authorName,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w700, fontSize: 13)),
                                        const SizedBox(width: 8),
                                        Text(timeAgo(comment.timestamp),
                                            style: const TextStyle(
                                                fontSize: 11, color: AppColors.textSecondary)),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(comment.text, style: const TextStyle(fontSize: 13.5, height: 1.4)),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Add a comment…',
                        isDense: true,
                        filled: true,
                        fillColor: AppColors.background,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Send comment',
                    onPressed: _send,
                    icon: const Icon(Icons.send_rounded, size: 20),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
