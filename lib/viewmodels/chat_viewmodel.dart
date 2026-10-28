import 'package:flutter/foundation.dart';

import '../models/community.dart';
import '../models/conversation.dart';
import '../repositories/chat_repository.dart';
import '../repositories/community_repository.dart';

/// ViewModel for the chats destination: tabs, search and the active
/// conversation (used by the desktop split view).
class ChatViewModel extends ChangeNotifier {
  ChatViewModel() {
    ChatRepository.instance.addListener(notifyListeners);
  }

  final ChatRepository _repo = ChatRepository.instance;

  int _tabIndex = 0; // 0 conversations, 1 requests, 2 groups
  String _query = '';
  String? _activeConversationId;

  int get tabIndex => _tabIndex;
  String get query => _query;
  String? get activeConversationId => _activeConversationId;
  int get requestCount => _repo.incomingRequests.length;
  Conversation? get activeConversation =>
      _activeConversationId == null ? null : _repo.byId(_activeConversationId!);

  void setTab(int index) {
    _tabIndex = index;
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void openConversation(String id) {
    _activeConversationId = id;
    _repo.markRead(id);
    notifyListeners();
  }

  void closeConversation() {
    _activeConversationId = null;
    notifyListeners();
  }

  List<Conversation> get conversations => _filterByName(_repo.accepted);
  List<Conversation> get requests => _filterByName(_repo.incomingRequests);
  List<Conversation> get outgoingRequests => _repo.outgoingRequests;
  List<Conversation> get groups => _filterByName(_repo.groups);

  List<Conversation> _filterByName(List<Conversation> list) {
    final normalized = _query.trim().toLowerCase();
    if (normalized.isEmpty) return list;
    return list
        .where((c) => c.peerName.toLowerCase().contains(normalized))
        .toList();
  }

  // Actions.
  void accept(String id) => _repo.acceptRequest(id);
  void decline(String id) => _repo.declineRequest(id);
  void cancelOutgoing(String id) => _repo.cancelOutgoingRequest(id);
  Future<void> send(String id, String text) => _repo.sendMessage(id, text);
  void block(String id) => _repo.block(id);
  void unblock(String id) => _repo.unblock(id);
  List<Conversation> get blocked => _repo.blocked;

  /// Communities entry point lives in the chats section.
  List<Community> get communities => CommunityRepository.instance.communities;
  int get joinedCommunities => communities.where((c) => c.joined).length;
}
