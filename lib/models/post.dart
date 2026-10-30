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
    this.backgroundId,
    List<String>? taggedNames,
    this.location,
    this.likedByMe = false,
    this.likeCount = 0,
    List<Comment>? comments,
    this.removedByAdmin = false,
    this.reportedByMe = false,
  })  : taggedNames = taggedNames ?? <String>[],
        comments = comments ?? <Comment>[];

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

  /// Facebook-style colour background chosen in the composer (`null` = plain).
  String? backgroundId;

  /// People tagged in the post ("with …").
  List<String> taggedNames;

  /// Check-in style location shown under the author's name.
  String? location;

  bool likedByMe;
  int likeCount;
  final List<Comment> comments;

  bool removedByAdmin;
  bool reportedByMe;

  bool get isAnnouncement => type != PostType.studentPost;
}

/// Everything the composer can produce — used to create a post or apply an
/// edit. Lives with the model layer so repositories never import UI code.
class PostDraft {
  const PostDraft({
    required this.content,
    this.withImage = false,
    this.backgroundId,
    this.taggedNames = const [],
    this.location,
  });

  final String content;
  final bool withImage;
  final String? backgroundId;
  final List<String> taggedNames;
  final String? location;
}
