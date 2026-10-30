import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/community.dart';
import '../models/enums.dart';
import '../models/student_profile.dart';
import 'chat_repository.dart';
import 'notification_repository.dart';

/// Simulated student communities.
///
/// FUTURE BACKEND INTEGRATION POINT (Supabase):
/// `communities` and `community_posts` tables plus Realtime subscriptions
/// for the community feed and group chat.
class CommunityRepository extends ChangeNotifier {
  CommunityRepository._();

  static final CommunityRepository instance = CommunityRepository._();

  final List<Community> communities = List.of(MockData.communities);

  Community? byId(String id) {
    for (final community in communities) {
      if (community.id == id) return community;
    }
    return null;
  }

  List<Community> byLevel(EducationLevel? level) => level == null
      ? communities
      : communities.where((c) => c.level == level).toList();

  /// Join (or request to join) a community.
  void join(String id, StudentProfile me) {
    final community = byId(id);
    if (community == null || community.joined) return;

    if (community.requiresApproval) {
      community.pendingJoin = true;
      NotificationRepository.instance.add(
        type: AppNotificationType.request,
        title: 'Join request sent',
        body: 'Your request to join ${community.name} is pending approval (demo).',
      );
    } else {
      _completeJoin(community);
    }
    notifyListeners();
  }

  /// Simulates approval of a pending join request (auto-approve after a tap).
  void approvePendingJoin(String id) {
    final community = byId(id);
    if (community == null || !community.pendingJoin) return;
    _completeJoin(community);
    notifyListeners();
  }

  void _completeJoin(Community community) {
    community.pendingJoin = false;
    community.joined = true;
    community.conversationId =
        ChatRepository.instance.ensureGroupConversation(community.name, community.memberCount);
  }

  void leave(String id) {
    final community = byId(id);
    if (community == null) return;
    community.joined = false;
    community.pendingJoin = false;
    community.conversationId = null;
    notifyListeners();
  }

  void postMessage(String id, StudentProfile me, String text) {
    final community = byId(id);
    if (community == null || !community.joined) return;
    community.feed.insert(
      0,
      CommunityPost(
        authorName: me.fullName,
        text: text.trim(),
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
