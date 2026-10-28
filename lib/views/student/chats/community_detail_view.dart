import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/forms.dart';
import '../../../core/widgets/responsive.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../models/enums.dart';
import '../../../repositories/auth_repository.dart';
import '../../../repositories/chat_repository.dart';
import '../../../repositories/community_repository.dart';
import '../chats/conversation_view.dart';

/// Community detail: info, join state, community feed and group chat entry.
class CommunityDetailView extends StatefulWidget {
  const CommunityDetailView({required this.communityId, super.key});

  final String communityId;

  @override
  State<CommunityDetailView> createState() => _CommunityDetailViewState();
}

class _CommunityDetailViewState extends State<CommunityDetailView> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _post() {
    final text = _controller.text.trim();
    final me = AuthRepository.instance.currentUser;
    if (text.isEmpty || me == null) return;
    CommunityRepository.instance.postMessage(widget.communityId, me, text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([CommunityRepository.instance, ChatRepository.instance]),
      builder: (context, _) {
        final community = CommunityRepository.instance.byId(widget.communityId);
        if (community == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Community')),
            body: const EmptyState(icon: Icons.groups_outlined, title: 'Community not available'),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(community.name, overflow: TextOverflow.ellipsis)),
          body: CenteredContent(
            maxWidth: 760,
            child: ListView(
              children: [
                // Header ------------------------------------------------
                SSCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.teal],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.forum_rounded, color: Colors.white, size: 26),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(community.name,
                                    style: const TextStyle(
                                        fontSize: 17, fontWeight: FontWeight.w800, height: 1.3)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    StatusPill(
                                        text: educationLevelLabel(community.level),
                                        color: AppColors.primary),
                                    const SizedBox(width: 6),
                                    Text('${community.memberCount} members',
                                        style: const TextStyle(
                                            fontSize: 12, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(community.description,
                          style: const TextStyle(fontSize: 13.5, height: 1.5, color: AppColors.textPrimary)),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(child: _JoinControl(communityId: community.id)),
                          if (community.joined) ...[
                            const SizedBox(width: 10),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                minimumSize: const Size(0, 44),
                                side: const BorderSide(color: AppColors.primary),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: community.conversationId == null
                                  ? null
                                  : () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ConversationView(
                                              conversationId: community.conversationId!),
                                        ),
                                      ),
                              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                              label: const Text('Group chat'),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Feed --------------------------------------------------
                const SectionHeader(title: 'Community feed'),
                if (!community.joined)
                  const EmptyState(
                    icon: Icons.lock_outline_rounded,
                    title: 'Join to see the community feed',
                    message: 'Members share updates, questions and resources here.',
                  )
                else ...[
                  SSCard(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _post(),
                            decoration: const InputDecoration(
                              hintText: 'Share something with the community…',
                              isDense: true,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Post',
                          onPressed: _post,
                          icon: const Icon(Icons.send_rounded, color: AppColors.teal),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (community.feed.isEmpty)
                    const EmptyState(
                      icon: Icons.forum_outlined,
                      title: 'No posts yet',
                      message: 'Be the first to start the discussion.',
                    )
                  else
                    for (final post in community.feed) ...[
                      SSCard(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                AvatarCircle(name: post.authorName, radius: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(post.authorName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700, fontSize: 13)),
                                      Text(timeAgo(post.timestamp),
                                          style: const TextStyle(
                                              fontSize: 11, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(post.text, style: const TextStyle(fontSize: 13.5, height: 1.4)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _JoinControl extends StatelessWidget {
  const _JoinControl({required this.communityId});

  final String communityId;

  @override
  Widget build(BuildContext context) {
    final community = CommunityRepository.instance.byId(communityId);
    if (community == null) return const SizedBox.shrink();
    final me = AuthRepository.instance.currentUser;

    if (community.joined) {
      return AppOutlinedButton(
        label: 'Leave community',
        onPressed: () async {
          final confirmed = await showConfirmDialog(
            context,
            title: 'Leave ${community.name}?',
            message: 'You will lose access to the community feed and group chat.',
            confirmLabel: 'Leave',
          );
          if (confirmed && context.mounted) {
            CommunityRepository.instance.leave(communityId);
            showAppSnackbar(context, 'Left the community.');
          }
        },
      );
    }

    if (community.pendingJoin) {
      return AppButton(
        label: 'Request pending — tap to simulate approval',
        onPressed: () {
          CommunityRepository.instance.approvePendingJoin(communityId);
          showAppSnackbar(context, 'Join request approved.');
        },
      );
    }

    return AppButton(
      label: community.requiresApproval ? 'Request to join' : 'Join community',
      onPressed: me == null ? null : () => CommunityRepository.instance.join(communityId, me),
    );
  }
}
