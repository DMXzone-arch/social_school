import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/friend_person.dart';

/// Simulated friends system: incoming requests, people you may know and
/// current friends.
///
/// FUTURE BACKEND INTEGRATION POINT (Supabase): back this with a
/// `friend_requests` table (`sender_id`, `recipient_id`, `status`) plus a
/// `friendships` table; use Supabase Realtime to push accepted requests and
/// new suggestions live. Request/accept/decline become RPC calls guarded by
/// row level security.
class FriendRepository extends ChangeNotifier {
  FriendRepository._();

  static final FriendRepository instance = FriendRepository._();

  final List<FriendPerson> _incoming = List.of(MockData.incomingFriendRequests);
  final List<FriendPerson> _suggestions = List.of(MockData.suggestedFriends);
  final List<FriendPerson> _friends = List.of(MockData.demoFriends);

  /// Suggestions the student already sent a request to this session.
  final Set<String> _requested = {};

  /// Number of pending incoming requests — drives the feed shortcut badge.
  int get pendingCount => _incoming.length;

  List<FriendPerson> get incoming => List.unmodifiable(_incoming);
  List<FriendPerson> get friends => List.unmodifiable(_friends);

  /// "People you may know" — hides anyone already added.
  List<FriendPerson> get suggestions => List.unmodifiable(
      _suggestions.where((person) => !_requested.contains(person.id)));

  /// True once a request has been sent to this suggestion.
  bool hasRequested(String personId) => _requested.contains(personId);

  /// Accepts an incoming request — the person becomes a friend.
  void accept(String personId) {
    final index = _incoming.indexWhere((person) => person.id == personId);
    if (index == -1) return;
    _friends.insert(0, _incoming.removeAt(index));
    notifyListeners();
  }

  /// Declines (or removes) an incoming request.
  void decline(String personId) {
    _incoming.removeWhere((person) => person.id == personId);
    notifyListeners();
  }

  /// Sends a friend request to a suggested person.
  void sendRequest(String personId) {
    _requested.add(personId);
    notifyListeners();
  }
}
