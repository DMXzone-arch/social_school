import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/admin.dart';
import '../models/conversation.dart';
import '../models/enums.dart';
import 'admin_repository.dart';
import 'notification_repository.dart';

/// Simulated chats with a mutual-approval messaging policy:
/// a conversation only opens after the recipient accepts the request.
///
/// FUTURE BACKEND INTEGRATION POINT (Supabase Realtime):
/// replace [messages] mutations with inserts into a `messages` table and
/// subscribe with `supabase.channel('chat')` for live delivery/read state.
class ChatRepository extends ChangeNotifier {
  ChatRepository._();

  static final ChatRepository instance = ChatRepository._();

  final List<Conversation> conversations = List.of(MockData.conversations);

  /// Restores the seeded sample data (admin "Reset demo data").
  void reseed() {
    conversations
      ..clear()
      ..addAll(MockData.conversations);
    notifyListeners();
  }

  List<Conversation> get accepted =>
      conversations.where((c) => !c.isRequest && !c.outgoingRequest).toList();
  List<Conversation> get incomingRequests =>
      conversations.where((c) => c.isRequest).toList();
  List<Conversation> get outgoingRequests =>
      conversations.where((c) => c.outgoingRequest).toList();
  List<Conversation> get groups =>
      conversations.where((c) => c.isGroup && c.accepted).toList();

  int get unreadCount =>
      accepted.fold(0, (sum, c) => sum + c.unreadCount);

  Conversation? byId(String id) {
    for (final conversation in conversations) {
      if (conversation.id == id) return conversation;
    }
    return null;
  }

  // --- Mutual-approval flow ------------------------------------------------

  /// Recipient accepts an incoming request → normal messaging unlocks.
  void acceptRequest(String id) {
    final conversation = byId(id);
    if (conversation == null) return;
    conversation.isRequest = false;
    conversation.accepted = true;
    NotificationRepository.instance.add(
      type: AppNotificationType.accepted,
      title: 'Request accepted',
      body: 'You accepted ${conversation.peerName}\'s request. You can now chat.',
    );
    notifyListeners();
  }

  void declineRequest(String id) {
    conversations.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  void cancelOutgoingRequest(String id) {
    conversations.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  /// Student sends a new conversation request (recipient must accept).
  Future<void> sendRequest(DemoStudentAccount target) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    conversations.add(
      Conversation(
        id: 'rq${DateTime.now().millisecondsSinceEpoch}',
        peerName: target.fullName,
        peerInstitution: target.institution,
        peerSubtitle: educationLevelLabel(target.level),
        isRequest: false,
        outgoingRequest: true,
        accepted: false,
        createdAt: DateTime.now(),
      ),
    );
    NotificationRepository.instance.add(
      type: AppNotificationType.request,
      title: 'Request sent',
      body: '${target.fullName} must accept before you can start chatting (demo).',
    );
    notifyListeners();
  }

  // --- Messaging -----------------------------------------------------------

  void markRead(String id) {
    final conversation = byId(id);
    if (conversation == null || conversation.unreadCount == 0) return;
    conversation.unreadCount = 0;
    notifyListeners();
  }

  /// Sends a demo message with simulated delivery/read states and a canned
  /// reply so the conversation feels interactive.
  Future<void> sendMessage(String id, String text) async {
    final conversation = byId(id);
    if (conversation == null || !conversation.canMessage) return;

    final message = Message(
      id: 'm${DateTime.now().millisecondsSinceEpoch}',
      text: text.trim(),
      fromMe: true,
      timestamp: DateTime.now(),
    );
    conversation.messages.add(message);
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 700));
    message.status = MessageStatus.delivered;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 900));
    message.status = MessageStatus.read;
    notifyListeners();

    if (conversation.isGroup) return; // no canned replies in group chats.

    await Future<void>.delayed(const Duration(milliseconds: 1200));
    conversation.messages.add(
      Message(
        id: 'm${DateTime.now().millisecondsSinceEpoch}',
        text: _cannedReply(),
        fromMe: false,
        timestamp: DateTime.now(),
        status: MessageStatus.read,
      ),
    );
    notifyListeners();
  }

  static const List<String> _replies = [
    'Asante! Let\'s discuss more in the library.',
    'Good question — I\'ll check my notes and get back to you.',
    'Sounds good 👍',
    'Zikomo for sharing that!',
  ];
  int _replyIndex = 0;

  String _cannedReply() {
    final reply = _replies[_replyIndex % _replies.length];
    _replyIndex++;
    return reply;
  }

  // --- Safety --------------------------------------------------------------

  void block(String id) {
    final conversation = byId(id);
    if (conversation == null) return;
    conversation.blocked = true;
    conversation.unreadCount = 0;
    NotificationRepository.instance.add(
      type: AppNotificationType.request,
      title: 'Account blocked',
      body: '${conversation.peerName} has been blocked (simulated).',
    );
    notifyListeners();
  }

  void unblock(String id) {
    final conversation = byId(id);
    if (conversation == null) return;
    conversation.blocked = false;
    notifyListeners();
  }

  List<Conversation> get blocked =>
      conversations.where((c) => c.blocked).toList();

  void report(String id, ModerationReason reason) {
    final conversation = byId(id);
    if (conversation == null) return;
    conversation.reported = true;
    AdminRepository.instance.createReport(
      target: ReportTarget.user,
      targetId: conversation.id,
      targetTitle: conversation.peerName,
      reason: reason,
      reporter: 'Demo Student',
    );
    notifyListeners();
  }

  /// Ensures a group conversation exists for a joined community.
  String ensureGroupConversation(String communityName, int memberCount) {
    final existing = conversations.where((c) => c.isGroup && c.peerName == communityName);
    if (existing.isNotEmpty) return existing.first.id;

    final id = 'gc${DateTime.now().millisecondsSinceEpoch}';
    conversations.add(
      Conversation(
        id: id,
        peerName: communityName,
        peerInstitution: 'Community group chat',
        peerSubtitle: '$memberCount members',
        isGroup: true,
        accepted: true,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
    return id;
  }
}
