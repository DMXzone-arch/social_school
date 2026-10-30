import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive.dart';
import '../../../core/widgets/states.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../repositories/friend_repository.dart';
import 'widgets/friend_tile.dart';

/// Friends hub: accept or decline incoming friend requests, send requests to
/// suggested people, and see current friends.
///
/// Reached from the home feed's "Friends" shortcut (which shows a badge for
/// pending requests).
class FriendsView extends StatelessWidget {
  const FriendsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Friends')),
      body: ListenableBuilder(
        listenable: FriendRepository.instance,
        builder: (context, _) {
          final repo = FriendRepository.instance;
          final incoming = repo.incoming;
          final suggestions = repo.suggestions;
          final friends = repo.friends;

          if (incoming.isEmpty && suggestions.isEmpty && friends.isEmpty) {
            return const EmptyState(
              icon: Icons.people_outline,
              title: 'No friends yet',
              message: 'Send requests to people you know — they appear here once accepted.',
            );
          }

          return CenteredContent(
            maxWidth: 680,
            child: ListView(
              children: [
                // Friend requests ----------------------------------------
                if (incoming.isNotEmpty) ...[
                  _SectionHeader(title: 'Friend requests', count: incoming.length),
                  for (final person in incoming) ...[
                    FriendTile(
                      person: person,
                      action: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _SmallButton(
                            label: 'Decline',
                            onPressed: () => repo.decline(person.id),
                          ),
                          const SizedBox(width: 6),
                          _SmallButton(
                            label: 'Add',
                            primary: true,
                            onPressed: () {
                              repo.accept(person.id);
                              _confirm(context, 'You and ${person.name.split(' ').first} are now friends.');
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],

                // People you may know ------------------------------------
                if (suggestions.isNotEmpty) ...[
                  const _SectionHeader(title: 'People you may know'),
                  for (final person in suggestions) ...[
                    FriendTile(
                      person: person,
                      action: repo.hasRequested(person.id)
                          ? Text('Request sent',
                              style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary))
                          : _SmallButton(
                              label: 'Add friend',
                              primary: true,
                              onPressed: () => repo.sendRequest(person.id),
                            ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],

                // Current friends ----------------------------------------
                if (friends.isNotEmpty) ...[
                  _SectionHeader(title: 'Your friends', count: friends.length),
                  for (final person in friends) ...[
                    FriendTile(person: person),
                    const SizedBox(height: 10),
                  ],
                ],
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirm(BuildContext context, String message) {
    showAppSnackbar(context, message);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.count});

  final String title;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 14, 2, 10),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          if (count != null) ...[
            const SizedBox(width: 6),
            Text('$count',
                style:
                    TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}

/// Compact list-tile action button used inside [FriendTile].
class _SmallButton extends StatelessWidget {
  const _SmallButton({required this.label, required this.onPressed, this.primary = false});

  final String label;
  final VoidCallback onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: primary ? AppColors.primary : AppColors.background,
        foregroundColor: primary ? Colors.white : AppColors.textPrimary,
        elevation: 0,
        minimumSize: const Size(0, 34),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        side: primary ? null : BorderSide(color: AppColors.border),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
