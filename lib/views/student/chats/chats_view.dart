import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/forms.dart';
import '../../../core/widgets/responsive.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../repositories/chat_repository.dart';
import '../../../viewmodels/chat_viewmodel.dart';
import 'communities_view.dart';
import 'conversation_view.dart';
import 'widgets/conversation_tile.dart';
import 'widgets/new_conversation_dialog.dart';

/// Chat inbox with Conversations / Requests / Groups tabs, search and a
/// desktop split view (list + active conversation).
class ChatsView extends StatelessWidget {
  const ChatsView({required this.viewModel, super.key});

  final ChatViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final isDesktop = screenTypeOf(context) == ScreenType.desktop;
        final active = viewModel.activeConversation;

        final listPanel = _InboxList(viewModel: viewModel, onOpenConversation: (id) {
          if (isDesktop) {
            viewModel.openConversation(id);
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ConversationView(conversationId: id)),
            );
          }
        });

        if (!isDesktop) return listPanel;

        return Row(
          children: [
            SizedBox(width: 340, child: listPanel),
            VerticalDivider(width: 1, color: AppColors.border),
            Expanded(
              child: active == null
                  ? const EmptyState(
                      icon: Icons.forum_outlined,
                      title: 'Select a conversation',
                      message: 'Pick a chat on the left, or browse communities.',
                    )
                  : ConversationView(conversationId: active.id, embedded: true),
            ),
          ],
        );
      },
    );
  }
}

class _InboxList extends StatelessWidget {
  const _InboxList({required this.viewModel, required this.onOpenConversation});

  final ChatViewModel viewModel;
  final ValueChanged<String> onOpenConversation;

  @override
  Widget build(BuildContext context) {
    return CenteredContent(
      maxWidth: 620,
      padding: const EdgeInsets.all(12),
      child: ListView(
        children: [
          // Header actions ---------------------------------------------
          Row(
            children: [
              const Expanded(
                child: Text('Chats', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size(0, 36),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CommunitiesView()),
                ),
                icon: const Icon(Icons.groups_outlined, size: 16),
                label: const Text('Communities', style: TextStyle(fontSize: 12.5)),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                tooltip: 'New conversation (sends a request)',
                onPressed: () => showNewConversationDialog(context),
                icon: const Icon(Icons.edit_note_rounded, size: 19),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppSearchField(hint: 'Search conversations…', onChanged: viewModel.setQuery),
          const SizedBox(height: 12),

          // Tabs ------------------------------------------------------
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                appFilterChip('Conversations', selected: viewModel.tabIndex == 0,
                    onTap: () => viewModel.setTab(0)),
                const SizedBox(width: 8),
                appFilterChip('Requests${viewModel.requestCount > 0 ? ' (${viewModel.requestCount})' : ''}',
                    selected: viewModel.tabIndex == 1, onTap: () => viewModel.setTab(1)),
                const SizedBox(width: 8),
                appFilterChip('Groups', selected: viewModel.tabIndex == 2, onTap: () => viewModel.setTab(2)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Tab content ------------------------------------------------
          if (viewModel.tabIndex == 0) ...[
            if (viewModel.conversations.isEmpty)
              const EmptyState(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'No conversations yet',
                message: 'Send a request to a classmate to start chatting.',
              )
            else
              for (final c in viewModel.conversations) ...[
                ConversationTile(conversation: c, onTap: () => onOpenConversation(c.id)),
                const SizedBox(height: 10),
              ],
          ],

          if (viewModel.tabIndex == 1) ...[
            if (viewModel.requests.isEmpty && viewModel.outgoingRequests.isEmpty)
              const EmptyState(
                icon: Icons.alternate_email_rounded,
                title: 'No pending requests',
                message: 'Requests appear here until both people accept.',
              ),
            for (final c in viewModel.requests) ...[
              _RequestTile(viewModel: viewModel, conversationId: c.id),
              const SizedBox(height: 10),
            ],
            if (viewModel.outgoingRequests.isNotEmpty) ...[
              const SectionHeader(title: 'Sent by you'),
              for (final c in viewModel.outgoingRequests) ...[
                ConversationTile(
                  conversation: c,
                  onTap: () {},
                  trailing: TextButton(
                    onPressed: () => viewModel.cancelOutgoing(c.id),
                    child: const Text('Cancel', style: TextStyle(fontSize: 12, color: AppColors.error)),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ],

          if (viewModel.tabIndex == 2) ...[
            if (viewModel.groups.isEmpty)
              const EmptyState(
                icon: Icons.groups_outlined,
                title: 'No group chats yet',
                message: 'Join a community to unlock its group conversation.',
              )
            else
              for (final c in viewModel.groups) ...[
                ConversationTile(conversation: c, onTap: () => onOpenConversation(c.id)),
                const SizedBox(height: 10),
              ],
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

}

class _RequestTile extends StatelessWidget {
  const _RequestTile({required this.viewModel, required this.conversationId});

  final ChatViewModel viewModel;
  final String conversationId;

  @override
  Widget build(BuildContext context) {
    final conversation = ChatRepository.instance.byId(conversationId);
    if (conversation == null) return const SizedBox.shrink();

    return SSCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConversationTile(conversation: conversation, onTap: () {}),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Accept',
                  expanded: false,
                  onPressed: () {
                    viewModel.accept(conversationId);
                    showAppSnackbar(context, 'You can now chat with ${conversation.peerName}.');
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppOutlinedButton(
                  label: 'Decline',
                  expanded: false,
                  onPressed: () => viewModel.decline(conversationId),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

