/// Delivery state of a demo chat message.
enum MessageStatus { sent, delivered, read }

/// A single chat message (simulated — never sent to a server).
class Message {
  Message({
    required this.id,
    required this.text,
    required this.fromMe,
    required this.timestamp,
    this.status = MessageStatus.sent,
  });

  final String id;
  final String text;
  final bool fromMe;
  final DateTime timestamp;
  MessageStatus status;
}

/// A direct conversation, a mutual-approval request or a group chat.
class Conversation {
  Conversation({
    required this.id,
    required this.peerName,
    required this.peerInstitution,
    this.peerSubtitle = '',
    List<Message>? messages,
    this.unreadCount = 0,
    this.isRequest = false,
    this.outgoingRequest = false,
    this.accepted = true,
    this.isGroup = false,
    this.blocked = false,
    this.reported = false,
    DateTime? createdAt,
  })  : messages = messages ?? <Message>[],
        createdAt = createdAt ?? DateTime.now();

  final String id;
  final String peerName;
  final String peerInstitution;
  final String peerSubtitle;
  final List<Message> messages;
  int unreadCount;

  /// Incoming mutual-approval request (needs accept/decline).
  bool isRequest;

  /// Outgoing request waiting for the other student to accept.
  bool outgoingRequest;
  bool accepted;
  bool isGroup;
  bool blocked;
  bool reported;
  final DateTime createdAt;

  DateTime get lastTimestamp =>
      messages.isEmpty ? createdAt : messages.last.timestamp;

  String get preview => messages.isEmpty
      ? (outgoingRequest
          ? 'Request pending — they must accept before you can chat'
          : 'No messages yet — say hello!')
      : messages.last.text;

  bool get canMessage => accepted && !isRequest && !outgoingRequest && !blocked;
}
