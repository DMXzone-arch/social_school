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

  Post? byId(String id) {
    for (final post in posts) {
      if (post.id == id) return post;
    }
    return null;
  }

  /// Creates a post for the signed-in student.
  Future<void> createPost(StudentProfile author, PostDraft draft) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    posts.insert(
      0,
      Post(
        id: 'p${DateTime.now().millisecondsSinceEpoch}',
        authorId: author.id,
        authorName: author.fullName,
        authorInstitution: author.institution.isEmpty ? 'Member' : author.institution,
        type: PostType.studentPost,
        content: draft.content.trim(),
        timestamp: DateTime.now(),
        hasImage: draft.withImage,
        backgroundId: draft.backgroundId,
        taggedNames: List.of(draft.taggedNames),
        location: draft.location,
      ),
    );
    notifyListeners();
  }

  Future<void> editPost(String id, PostDraft draft) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final post = byId(id);
    if (post != null) {
      post.content = draft.content.trim();
      post.backgroundId = draft.backgroundId;
      post.taggedNames = List.of(draft.taggedNames);
      post.location = draft.location;
    }
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

  /// Feed content for the given search query (the feed itself shows every
  /// post, newest first — no filters).
  List<Post> filtered({String query = ''}) {
    final normalized = query.trim().toLowerCase();
    return posts.where((post) {
      if (post.removedByAdmin) return false;

      if (normalized.isEmpty) return true;
      return post.content.toLowerCase().contains(normalized) ||
          post.authorName.toLowerCase().contains(normalized) ||
          (post.title?.toLowerCase().contains(normalized) ?? false);
    }).toList();
  }
}
