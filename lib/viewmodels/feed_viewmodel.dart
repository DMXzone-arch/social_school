import 'package:flutter/foundation.dart';

import '../models/enums.dart';
import '../models/post.dart';
import '../models/student_profile.dart';
import '../repositories/auth_repository.dart';
import '../repositories/feed_repository.dart';

/// ViewModel for the home feed: holds search state and delegates data work
/// to [FeedRepository].
class FeedViewModel extends ChangeNotifier {
  FeedViewModel() {
    FeedRepository.instance.addListener(notifyListeners);
    _repo.load();
  }

  final FeedRepository _repo = FeedRepository.instance;
  final AuthRepository _auth = AuthRepository.instance;

  String _query = '';

  String get query => _query;
  bool get loading => _repo.loading;
  bool get loaded => _repo.loaded;

  StudentProfile get _me => _auth.currentUser ?? _demoProfile;

  void setQuery(String query) {
    _query = query;
    notifyListeners();
  }

  Future<void> refresh() => _repo.load();

  Future<void> retry() async {
    _repo.loaded = false;
    await _repo.load();
  }

  List<Post> get visiblePosts => _repo.filtered(query: _query);

  // Convenience actions used by the view layer.
  Future<void> createPost(PostDraft draft) => _repo.createPost(_me, draft);
  Future<void> editPost(String id, PostDraft draft) => _repo.editPost(id, draft);
  void deletePost(String id) => _repo.deletePost(id);
  void toggleLike(String id) => _repo.toggleLike(id);
  Future<void> addComment(String id, String text) => _repo.addComment(id, _me, text);
  int commentCount(String id) => _repo.byId(id)?.comments.length ?? 0;

  static final StudentProfile _demoProfile = StudentProfile(
    id: 'me',
    fullName: 'Member',
    email: '',
    educationLevel: EducationLevel.university,
    country: 'Malawi',
    institution: '',
    interests: [],
  );
}
