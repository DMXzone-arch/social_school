import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/ui_kit.dart';
import '../../../../models/community.dart';
import '../../../../models/enums.dart';
import '../../../../repositories/auth_repository.dart';
import '../../../../repositories/community_repository.dart';

/// Reusable community card with Join / Request to Join / Joined states.
class CommunityCard extends StatelessWidget {
  const CommunityCard({required this.community, this.onOpen, super.key});

  final Community community;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final c = community;

    return SSCard(
      onTap: onOpen,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.teal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.forum_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(c.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(c.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4)),
          const SizedBox(height: 10),
          Row(
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        educationLevelLabel(c.level),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.people_outline_rounded, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        '${c.memberCount} members',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _JoinButton(community: c),
            ],
          ),
        ],
      ),
    );
  }
}

class _JoinButton extends StatelessWidget {
  const _JoinButton({required this.community});

  final Community community;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CommunityRepository.instance,
      builder: (context, _) {
        final c = CommunityRepository.instance.byId(community.id) ?? community;

        if (c.joined) {
          return const StatusPill(text: '✓ Joined', color: AppColors.success);
        }
        if (c.pendingJoin) {
          return const StatusPill(text: 'Pending approval', color: Color(0xFFB45309));
        }

        final me = AuthRepository.instance.currentUser;
        if (me == null) return const SizedBox.shrink();

        final label = c.requiresApproval ? 'Request to join' : 'Join';
        return OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            minimumSize: const Size(0, 32),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          ),
          onPressed: () => CommunityRepository.instance.join(c.id, me),
          child: Text(label),
        );
      },
    );
  }
}
