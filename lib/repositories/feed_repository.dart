import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/enums.dart';
import '../models/post.dart';
import '../models/student_profile.dart';

/// Simulated home feed.
///
/// FUTURE BACKEND INTEGRATION POINT (Supabase):
/// replace the in-memory [posts] list with `supabase.from('posts').select()`
/// calls, and use Supabase Realtime for live updates. Reactions and comments
/// map naturally onto Supabase tables + row level security.
class FeedRepository extends ChangeNotifier {
  FeedRepository._();

  static final FeedRepository instance = FeedRepository._();

  final List<Post> posts = List.of(MockData.posts);
  int _seq = 0;

  bool loaded = false;
  bool loading = false;

  /// Simulates the initial feed request (loading placeholders).
  Future<void> load() async {
    if (loaded || loading) return;
    loading = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 700));
    loading = false;
    loaded = true;
    notifyListeners();
  }

  /// Restores the seeded sample data (admin "Reset demo data").
  void reseed() {
    posts
      ..clear()
      ..addAll(MockData.posts);
    loaded = false;
    loading = false;
    notifyListeners();
  }

  Post? byId(String id) {
    for (final post in posts) {
      if (post.id == id) return post;
    }
    return null;
  }

  /// Creates a post for the signed-in student.
  Future<void> createPost(StudentProfile author, String content, {bool withImage = false}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    posts.insert(
      0,
      Post(
        id: 'p${DateTime.now().millisecondsSinceEpoch}',
        authorId: author.id,
        authorName: author.fullName,
        authorInstitution: author.institution.isEmpty ? 'Student' : author.institution,
        type: PostType.studentPost,
        content: content.trim(),
        timestamp: DateTime.now(),
        hasImage: withImage,
      ),
    );
    notifyListeners();
  }

  Future<void> editPost(String id, String content) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final post = byId(id);
    if (post != null) post.content = content.trim();
    notifyListeners();
  }

  void deletePost(String id) {
    posts.removeWhere((post) => post.id == id);
    notifyListeners();
  }

  void toggleLike(String id) {
    final post = byId(id);
    if (post == null) return;
    post.likedByMe = !post.likedByMe;
    post.likeCount += post.likedByMe ? 1 : -1;
    notifyListeners();
  }

  Future<void> addComment(String id, StudentProfile author, String text) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final post = byId(id);
    if (post == null) return;
    post.comments.add(
      Comment(
        id: 'c${_seq++}',
        authorName: author.fullName,
        text: text.trim(),
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void markReported(String id) {
    final post = byId(id);
    if (post != null) post.reportedByMe = true;
    notifyListeners();
  }

  // --- Admin actions -------------------------------------------------------

  /// Publishes an admin announcement (admin app → student feed).
  Future<void> publishAnnouncement(String title, String body) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    posts.insert(
      0,
      Post(
        id: 'p${DateTime.now().millisecondsSinceEpoch}',
        authorId: null,
        authorName: 'Social School Admin',
        authorInstitution: 'Social School',
        type: PostType.adminAnnouncement,
        title: title.trim(),
        content: body.trim(),
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void adminRemovePost(String id) {
    final post = byId(id);
    if (post != null) post.removedByAdmin = true;
    notifyListeners();
  }

  void adminRestorePost(String id) {
    final post = byId(id);
    if (post != null) post.removedByAdmin = false;
    notifyListeners();
  }

  /// Feed content for the given filter + search query.
  List<Post> filtered({
    required StudentProfile me,
    FeedFilter filter = FeedFilter.forYou,
    String query = '',
  }) {
    final normalized = query.trim().toLowerCase();
    return posts.where((post) {
      if (post.removedByAdmin) return false;

      final matchesSwitch = switch (filter) {
        FeedFilter.forYou => true,
        FeedFilter.myInstitution =>
          post.authorInstitution == me.institution || post.type == PostType.adminAnnouncement,
        FeedFilter.following => post.authorId != null && _following.contains(post.authorId),
      };
      if (!matchesSwitch) return false;

      if (normalized.isEmpty) return true;
      return post.content.toLowerCase().contains(normalized) ||
          post.authorName.toLowerCase().contains(normalized) ||
          (post.title?.toLowerCase().contains(normalized) ?? false);
    }).toList();
  }

  /// Demo "following" list for the signed-in student.
  static const Set<String> _following = {'u2', 'u3', 'u7'};
}
