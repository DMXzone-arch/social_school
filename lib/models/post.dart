import 'enums.dart';

/// A comment on a feed post.
class Comment {
  Comment({
    required this.id,
    required this.authorName,
    required this.text,
    required this.timestamp,
  });

  final String id;
  final String authorName;
  final String text;
  final DateTime timestamp;
}

/// A feed post: student post, school announcement or admin announcement.
class Post {
  Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorInstitution,
    required this.type,
    required this.content,
    required this.timestamp,
    this.title,
    this.hasImage = false,
    this.likedByMe = false,
    this.likeCount = 0,
    List<Comment>? comments,
    this.removedByAdmin = false,
    this.reportedByMe = false,
  })  : comments = comments ?? <Comment>[];

  final String id;

  /// `null` for school/admin announcements.
  final String? authorId;
  final String authorName;
  final String authorInstitution;
  final PostType type;

  /// Optional headline used by announcements.
  final String? title;
  String content;
  final DateTime timestamp;

  /// True when the composer attached a simulated local image.
  final bool hasImage;

  bool likedByMe;
  int likeCount;
  final List<Comment> comments;

  bool removedByAdmin;
  bool reportedByMe;

  bool get isAnnouncement => type != PostType.studentPost;
}
