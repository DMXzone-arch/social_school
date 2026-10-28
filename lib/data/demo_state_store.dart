import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/admin.dart';
import '../models/community.dart';
import '../models/conversation.dart';
import '../models/enums.dart';
import '../models/notification_item.dart';
import '../models/opportunity.dart';
import '../models/post.dart';
import '../models/resource.dart';
import '../repositories/admin_repository.dart';
import '../repositories/chat_repository.dart';
import '../repositories/community_repository.dart';
import '../repositories/feed_repository.dart';
import '../repositories/library_repository.dart';
import '../repositories/notification_repository.dart';
import '../repositories/opportunity_repository.dart';

/// Persists the simulated demo state to local storage (browser localStorage
/// on web) so the **separate** student app and admin app can see each
/// other's changes.
///
/// PROTOTYPE BEHAVIOUR — clearly labelled:
/// - Nothing is sent to a server; the data lives only in this device/browser.
/// - State is saved a moment after each change and restored on app start.
/// - Use "Reset demo data" (admin → Storage & Settings) to reseed everything.
///
/// FUTURE BACKEND INTEGRATION POINT: this whole class disappears once
/// Supabase (data) + Cloudflare R2 (files) are connected — repositories will
/// read/write the real backend instead of this local snapshot.
class DemoStateStore {
  DemoStateStore._();

  static final DemoStateStore instance = DemoStateStore._();

  static const String _storageKey = 'social_school_demo_state_v1';

  SharedPreferences? _prefs;
  Timer? _debounce;

  /// Loads local storage. Safe to call before `runApp`.
  Future<void> load() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (_) {
      // Local storage unavailable (e.g. some test environments) — the app
      // still runs fully in-memory.
      _prefs = null;
    }
  }

  /// Restores the saved demo world (if any) into the repositories.
  /// Call once at startup, before `runApp`.
  void restoreSavedWorld() {
    final raw = _prefs?.getString(_storageKey);
    if (raw == null) return;
    try {
      _apply(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // Corrupt snapshot — fall back to the seeded mock data.
    }
  }

  /// Attaches debounced auto-saving to every repository.
  /// Call once at startup, after [restoreSavedWorld].
  void attachAutoSave() {
    final repos = <Listenable>[
      FeedRepository.instance,
      LibraryRepository.instance,
      ChatRepository.instance,
      CommunityRepository.instance,
      OpportunityRepository.instance,
      NotificationRepository.instance,
      AdminRepository.instance,
    ];
    for (final repo in repos) {
      repo.addListener(scheduleSave);
    }
  }

  void scheduleSave() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), saveNow);
  }

  void saveNow() {
    if (_prefs == null) return;
    try {
      _prefs!.setString(_storageKey, jsonEncode(_serialize()));
    } catch (_) {
      // Prototype: ignore persistence failures.
    }
  }

  /// Clears the snapshot and reseeds repositories from [MockData].
  void resetDemoData() {
    _prefs?.remove(_storageKey);
    FeedRepository.instance.reseed();
    LibraryRepository.instance.reseed();
    ChatRepository.instance.reseed();
    CommunityRepository.instance.reseed();
    OpportunityRepository.instance.reseed();
    NotificationRepository.instance.reseed();
    AdminRepository.instance.reseed();
  }

  // -------------------------------------------------------------------------
  // Serialization
  // -------------------------------------------------------------------------

  Map<String, dynamic> _serialize() => {
        'posts': FeedRepository.instance.posts.map(_postToMap).toList(),
        'resources': LibraryRepository.instance.resources.map(_resourceToMap).toList(),
        'conversations': ChatRepository.instance.conversations.map(_conversationToMap).toList(),
        'communities': CommunityRepository.instance.communities.map(_communityToMap).toList(),
        'opportunities': OpportunityRepository.instance.opportunities.map(_opportunityToMap).toList(),
        'notifications': NotificationRepository.instance.items.map(_notificationToMap).toList(),
        'reports': AdminRepository.instance.reports.map(_reportToMap).toList(),
        'auditLog': AdminRepository.instance.auditLog.map(_auditToMap).toList(),
        'users': AdminRepository.instance.users.map(_userToMap).toList(),
        'institutions': AdminRepository.instance.institutions.map(_institutionToMap).toList(),
      };

  void _apply(Map<String, dynamic> data) {
    _replace(FeedRepository.instance.posts, data['posts'], _postFromMap);
    _replace(LibraryRepository.instance.resources, data['resources'], _resourceFromMap);
    _replace(ChatRepository.instance.conversations, data['conversations'], _conversationFromMap);
    _replace(CommunityRepository.instance.communities, data['communities'], _communityFromMap);
    _replace(OpportunityRepository.instance.opportunities, data['opportunities'], _opportunityFromMap);
    _replace(NotificationRepository.instance.items, data['notifications'], _notificationFromMap);
    _replace(AdminRepository.instance.reports, data['reports'], _reportFromMap);
    _replace(AdminRepository.instance.auditLog, data['auditLog'], _auditFromMap);
    _replace(AdminRepository.instance.users, data['users'], _userFromMap);
    _replace(AdminRepository.instance.institutions, data['institutions'], _institutionFromMap);
  }

  static void _replace<T>(List<T> target, dynamic raw, T Function(Map<String, dynamic>) fromMap) {
    if (raw is! List) return;
    target
      ..clear()
      ..addAll(raw.cast<Map<String, dynamic>>().map(fromMap));
  }

  // --- enum helpers ---------------------------------------------------------

  static String _enumName(Enum value) => value.name;

  static T _enumByName<T extends Enum>(List<T> values, String? name, {required T fallback}) {
    if (name == null) return fallback;
    for (final value in values) {
      if (value.name == name) return value;
    }
    return fallback;
  }

  // --- posts ----------------------------------------------------------------

  static Map<String, dynamic> _postToMap(Post p) => {
        'id': p.id,
        'authorId': p.authorId,
        'authorName': p.authorName,
        'authorInstitution': p.authorInstitution,
        'type': _enumName(p.type),
        'title': p.title,
        'content': p.content,
        'timestamp': p.timestamp.toIso8601String(),
        'hasImage': p.hasImage,
        'likedByMe': p.likedByMe,
        'likeCount': p.likeCount,
        'comments': p.comments
            .map((c) => {
                  'id': c.id,
                  'authorName': c.authorName,
                  'text': c.text,
                  'timestamp': c.timestamp.toIso8601String(),
                })
            .toList(),
        'removedByAdmin': p.removedByAdmin,
      };

  static Post _postFromMap(Map<String, dynamic> m) => Post(
        id: m['id'] as String,
        authorId: m['authorId'] as String?,
        authorName: m['authorName'] as String,
        authorInstitution: m['authorInstitution'] as String,
        type: _enumByName(PostType.values, m['type'] as String?, fallback: PostType.studentPost),
        title: m['title'] as String?,
        content: m['content'] as String,
        timestamp: DateTime.parse(m['timestamp'] as String),
        hasImage: m['hasImage'] as bool? ?? false,
        likedByMe: m['likedByMe'] as bool? ?? false,
        likeCount: m['likeCount'] as int? ?? 0,
        comments: [
          for (final c in (m['comments'] as List? ?? const []))
            Comment(
              id: c['id'] as String,
              authorName: c['authorName'] as String,
              text: c['text'] as String,
              timestamp: DateTime.parse(c['timestamp'] as String),
            ),
        ],
        removedByAdmin: m['removedByAdmin'] as bool? ?? false,
      );

  // --- resources ------------------------------------------------------------

  static Map<String, dynamic> _resourceToMap(LibraryResource r) => {
        'id': r.id,
        'title': r.title,
        'description': r.description,
        'subject': r.subject,
        'level': _enumName(r.level),
        'institution': r.institution,
        'category': _enumName(r.category),
        'author': r.author,
        'fileType': r.fileType,
        'fileSize': r.fileSize,
        'fileSizeMb': r.fileSizeMb,
        'dateAdded': r.dateAdded.toIso8601String(),
        'status': _enumName(r.status),
        'submittedBy': r.submittedBy,
        'downloadCount': r.downloadCount,
        'rejectionReason': r.rejectionReason,
        'bookmarked': r.bookmarked,
        'downloadState': _enumName(r.downloadState),
      };

  static LibraryResource _resourceFromMap(Map<String, dynamic> m) => LibraryResource(
        id: m['id'] as String,
        title: m['title'] as String,
        description: m['description'] as String,
        subject: m['subject'] as String,
        level: _enumByName(EducationLevel.values, m['level'] as String?,
            fallback: EducationLevel.secondary),
        institution: m['institution'] as String,
        category: _enumByName(ResourceCategory.values, m['category'] as String?,
            fallback: ResourceCategory.generalAcademic),
        author: m['author'] as String,
        fileType: m['fileType'] as String,
        fileSize: m['fileSize'] as String,
        fileSizeMb: (m['fileSizeMb'] as num?)?.toDouble() ?? 0,
        dateAdded: DateTime.parse(m['dateAdded'] as String),
        status: _enumByName(ResourceStatus.values, m['status'] as String?,
            fallback: ResourceStatus.pendingReview),
        submittedBy: m['submittedBy'] as String? ?? 'Demo uploader',
        downloadCount: m['downloadCount'] as int? ?? 0,
        rejectionReason: m['rejectionReason'] as String?,
        bookmarked: m['bookmarked'] as bool? ?? false,
        downloadState: _enumByName(DownloadState.values, m['downloadState'] as String?,
            fallback: DownloadState.none),
      );

  // --- conversations --------------------------------------------------------

  static Map<String, dynamic> _conversationToMap(Conversation c) => {
        'id': c.id,
        'peerName': c.peerName,
        'peerInstitution': c.peerInstitution,
        'peerSubtitle': c.peerSubtitle,
        'unreadCount': c.unreadCount,
        'isRequest': c.isRequest,
        'outgoingRequest': c.outgoingRequest,
        'accepted': c.accepted,
        'isGroup': c.isGroup,
        'blocked': c.blocked,
        'reported': c.reported,
        'createdAt': c.createdAt.toIso8601String(),
        'messages': c.messages
            .map((m) => {
                  'id': m.id,
                  'text': m.text,
                  'fromMe': m.fromMe,
                  'timestamp': m.timestamp.toIso8601String(),
                  'status': _enumName(m.status),
                })
            .toList(),
      };

  static Conversation _conversationFromMap(Map<String, dynamic> m) => Conversation(
        id: m['id'] as String,
        peerName: m['peerName'] as String,
        peerInstitution: m['peerInstitution'] as String,
        peerSubtitle: m['peerSubtitle'] as String? ?? '',
        unreadCount: m['unreadCount'] as int? ?? 0,
        isRequest: m['isRequest'] as bool? ?? false,
        outgoingRequest: m['outgoingRequest'] as bool? ?? false,
        accepted: m['accepted'] as bool? ?? true,
        isGroup: m['isGroup'] as bool? ?? false,
        blocked: m['blocked'] as bool? ?? false,
        reported: m['reported'] as bool? ?? false,
        createdAt: DateTime.parse(m['createdAt'] as String),
        messages: [
          for (final msg in (m['messages'] as List? ?? const []))
            Message(
              id: msg['id'] as String,
              text: msg['text'] as String,
              fromMe: msg['fromMe'] as bool,
              timestamp: DateTime.parse(msg['timestamp'] as String),
              status: _enumByName(MessageStatus.values, msg['status'] as String?,
                  fallback: MessageStatus.sent),
            ),
        ],
      );

  // --- communities ----------------------------------------------------------

  static Map<String, dynamic> _communityToMap(Community c) => {
        'id': c.id,
        'name': c.name,
        'description': c.description,
        'level': _enumName(c.level),
        'memberCount': c.memberCount,
        'requiresApproval': c.requiresApproval,
        'joined': c.joined,
        'pendingJoin': c.pendingJoin,
        'conversationId': c.conversationId,
        'feed': c.feed
            .map((p) => {
                  'authorName': p.authorName,
                  'text': p.text,
                  'timestamp': p.timestamp.toIso8601String(),
                })
            .toList(),
      };

  static Community _communityFromMap(Map<String, dynamic> m) => Community(
        id: m['id'] as String,
        name: m['name'] as String,
        description: m['description'] as String,
        level: _enumByName(EducationLevel.values, m['level'] as String?,
            fallback: EducationLevel.secondary),
        memberCount: m['memberCount'] as int,
        requiresApproval: m['requiresApproval'] as bool? ?? false,
        joined: m['joined'] as bool? ?? false,
        pendingJoin: m['pendingJoin'] as bool? ?? false,
        conversationId: m['conversationId'] as String?,
        feed: [
          for (final p in (m['feed'] as List? ?? const []))
            CommunityPost(
              authorName: p['authorName'] as String,
              text: p['text'] as String,
              timestamp: DateTime.parse(p['timestamp'] as String),
            ),
        ],
      );

  // --- opportunities --------------------------------------------------------

  static Map<String, dynamic> _opportunityToMap(Opportunity o) => {
        'id': o.id,
        'title': o.title,
        'provider': o.provider,
        'category': _enumName(o.category),
        'level': _enumName(o.level),
        'eligibility': o.eligibility,
        'deadline': o.deadline.toIso8601String(),
        'location': o.location,
        'description': o.description,
        'requiredDocuments': o.requiredDocuments,
        'instructions': o.instructions,
        'remote': o.remote,
        'verified': o.verified,
        'published': o.published,
      };

  static Opportunity _opportunityFromMap(Map<String, dynamic> m) => Opportunity(
        id: m['id'] as String,
        title: m['title'] as String,
        provider: m['provider'] as String,
        category: _enumByName(OpportunityCategory.values, m['category'] as String?,
            fallback: OpportunityCategory.training),
        level: _enumByName(EducationLevel.values, m['level'] as String?,
            fallback: EducationLevel.university),
        eligibility: m['eligibility'] as String,
        deadline: DateTime.parse(m['deadline'] as String),
        location: m['location'] as String,
        description: m['description'] as String,
        requiredDocuments: (m['requiredDocuments'] as List? ?? const []).cast<String>(),
        instructions: m['instructions'] as String,
        remote: m['remote'] as bool? ?? false,
        verified: m['verified'] as bool? ?? false,
        published: m['published'] as bool? ?? true,
      );

  // --- notifications --------------------------------------------------------

  static Map<String, dynamic> _notificationToMap(AppNotification n) => {
        'id': n.id,
        'type': _enumName(n.type),
        'title': n.title,
        'body': n.body,
        'timestamp': n.timestamp.toIso8601String(),
        'read': n.read,
      };

  static AppNotification _notificationFromMap(Map<String, dynamic> m) => AppNotification(
        id: m['id'] as String,
        type: _enumByName(AppNotificationType.values, m['type'] as String?,
            fallback: AppNotificationType.adminAnnouncement),
        title: m['title'] as String,
        body: m['body'] as String,
        timestamp: DateTime.parse(m['timestamp'] as String),
        read: m['read'] as bool? ?? false,
      );

  // --- admin: reports, audit, users, institutions ---------------------------

  static Map<String, dynamic> _reportToMap(Report r) => {
        'id': r.id,
        'target': _enumName(r.target),
        'targetId': r.targetId,
        'targetTitle': r.targetTitle,
        'reason': _enumName(r.reason),
        'reporter': r.reporter,
        'timestamp': r.timestamp.toIso8601String(),
        'status': _enumName(r.status),
        'notes': r.notes,
      };

  static Report _reportFromMap(Map<String, dynamic> m) => Report(
        id: m['id'] as String,
        target: _enumByName(ReportTarget.values, m['target'] as String?,
            fallback: ReportTarget.post),
        targetId: m['targetId'] as String,
        targetTitle: m['targetTitle'] as String,
        reason: _enumByName(ModerationReason.values, m['reason'] as String?,
            fallback: ModerationReason.inappropriate),
        reporter: m['reporter'] as String,
        timestamp: DateTime.parse(m['timestamp'] as String),
        status: _enumByName(ReportStatus.values, m['status'] as String?,
            fallback: ReportStatus.open),
        notes: m['notes'] as String? ?? '',
      );

  static Map<String, dynamic> _auditToMap(AuditEntry a) => {
        'id': a.id,
        'adminName': a.adminName,
        'action': a.action,
        'timestamp': a.timestamp.toIso8601String(),
      };

  static AuditEntry _auditFromMap(Map<String, dynamic> m) => AuditEntry(
        id: m['id'] as String,
        adminName: m['adminName'] as String,
        action: m['action'] as String,
        timestamp: DateTime.parse(m['timestamp'] as String),
      );

  static Map<String, dynamic> _userToMap(DemoStudentAccount u) => {
        'id': u.id,
        'fullName': u.fullName,
        'email': u.email,
        'level': _enumName(u.level),
        'institution': u.institution,
        'registered': u.registered.toIso8601String(),
        'status': _enumName(u.status),
      };

  static DemoStudentAccount _userFromMap(Map<String, dynamic> m) => DemoStudentAccount(
        id: m['id'] as String,
        fullName: m['fullName'] as String,
        email: m['email'] as String,
        level: _enumByName(EducationLevel.values, m['level'] as String?,
            fallback: EducationLevel.secondary),
        institution: m['institution'] as String,
        registered: DateTime.parse(m['registered'] as String),
        status: _enumByName(AccountStatus.values, m['status'] as String?,
            fallback: AccountStatus.active),
      );

  static Map<String, dynamic> _institutionToMap(Institution i) => {
        'id': i.id,
        'name': i.name,
        'type': _enumName(i.type),
        'location': i.location,
        'programmes': i.programmes,
      };

  static Institution _institutionFromMap(Map<String, dynamic> m) => Institution(
        id: m['id'] as String,
        name: m['name'] as String,
        type: _enumByName(InstitutionType.values, m['type'] as String?,
            fallback: InstitutionType.secondary),
        location: m['location'] as String,
        programmes: (m['programmes'] as List? ?? const []).cast<String>(),
      );
}
