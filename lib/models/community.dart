import 'enums.dart';

/// A message posted in a community feed (demo).
class CommunityPost {
  CommunityPost({
    required this.authorName,
    required this.text,
    required this.timestamp,
  });

  final String authorName;
  final String text;
  final DateTime timestamp;
}

/// A student community/group.
class Community {
  Community({
    required this.id,
    required this.name,
    required this.description,
    required this.level,
    required this.memberCount,
    this.requiresApproval = false,
    this.joined = false,
    this.pendingJoin = false,
    this.conversationId,
    List<CommunityPost>? feed,
  }) : feed = feed ?? <CommunityPost>[];

  final String id;
  final String name;
  final String description;
  final EducationLevel level;
  final int memberCount;
  final bool requiresApproval;
  bool joined;
  bool pendingJoin;

  /// Id of the linked group conversation once joined.
  String? conversationId;
  final List<CommunityPost> feed;
}
