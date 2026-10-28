import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/admin.dart';
import '../models/enums.dart';
import '../models/opportunity.dart';
import '../models/resource.dart';
import 'chat_repository.dart';
import 'feed_repository.dart';
import 'library_repository.dart';
import 'notification_repository.dart';
import 'opportunity_repository.dart';

/// Central administration layer: moderation, users, institutions, audit log.
///
/// Admin actions delegate to the owning repository and append an audit entry,
/// which keeps the shared demo state consistent between the admin app and
/// the student app (e.g. approving a resource makes it appear in the
/// student library immediately).
///
/// FUTURE BACKEND INTEGRATION POINT (Supabase):
/// protect every method behind Supabase row level security with an
/// `is_admin` claim; replace lists with table queries and audit entries
/// with an `audit_log` insert.
class AdminRepository extends ChangeNotifier {
  AdminRepository._();

  static final AdminRepository instance = AdminRepository._();

  bool signedIn = false;
  static const String adminName = 'Demo Admin';

  final List<Report> reports = List.of(MockData.reports);
  final List<AuditEntry> auditLog = List.of(MockData.auditLog);
  final List<DemoStudentAccount> users = List.of(MockData.studentAccounts);
  final List<Institution> institutions = List.of(MockData.institutions);

  /// Restores the seeded sample data (admin "Reset demo data").
  void reseed() {
    reports
      ..clear()
      ..addAll(MockData.reports);
    auditLog
      ..clear()
      ..addAll(MockData.auditLog);
    users
      ..clear()
      ..addAll(MockData.studentAccounts);
    institutions
      ..clear()
      ..addAll(MockData.institutions);
    notifyListeners();
  }

  // --- Session -------------------------------------------------------------

  /// Simulated admin sign-in (any valid-looking credentials work).
  Future<void> signIn({required String email, required String password}) async {
    if (!RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(email.trim())) {
      throw ArgumentError('Please enter a valid email address.');
    }
    if (password.length < 6) throw ArgumentError('Password must be at least 6 characters.');
    await Future<void>.delayed(const Duration(milliseconds: 600));
    signedIn = true;
    log('Admin signed in (simulated)');
    notifyListeners();
  }

  void signOut() {
    signedIn = false;
    notifyListeners();
  }

  // --- Audit log -----------------------------------------------------------

  void log(String action) {
    auditLog.insert(
      0,
      AuditEntry(
        id: 'a${DateTime.now().millisecondsSinceEpoch}',
        adminName: adminName,
        action: action,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  // --- Dashboard statistics (all demo figures) -----------------------------

  int get totalStudents => users.length + 1247;
  int get activeUsers => users.where((u) => u.status == AccountStatus.active).length + 1180;
  int get publishedResources =>
      LibraryRepository.instance.resources.where((r) => r.status == ResourceStatus.approved).length;
  int get pendingResources =>
      LibraryRepository.instance.resources.where((r) => r.status == ResourceStatus.pendingReview).length;
  int get publishedOpportunities =>
      OpportunityRepository.instance.opportunities.where((o) => o.published).length;
  int get pendingReports => reports.where((r) => r.status == ReportStatus.open).length;

  /// Illustrative storage figure (demo only — no real bucket).
  double get totalStorageMb =>
      LibraryRepository.instance.resources.fold(0.0, (sum, r) => sum + r.fileSizeMb);
  double get averageFileMb {
    final list = LibraryRepository.instance.resources;
    if (list.isEmpty) return 0;
    return totalStorageMb / list.length;
  }

  Map<String, double> get fileTypeDistribution {
    final distribution = <String, double>{};
    for (final resource in LibraryRepository.instance.resources) {
      distribution.update(
        resource.fileType,
        (value) => value + resource.fileSizeMb,
        ifAbsent: () => resource.fileSizeMb,
      );
    }
    return distribution;
  }

  // --- Resource moderation (shared with student library) -------------------

  void approveResource(String id) {
    final resource = LibraryRepository.instance.byId(id);
    LibraryRepository.instance.approve(id);
    log('Approved resource "${resource?.title ?? id}"');
  }

  void rejectResource(String id, String reason) {
    final resource = LibraryRepository.instance.byId(id);
    LibraryRepository.instance.reject(id, reason);
    log('Rejected resource "${resource?.title ?? id}" — $reason');
  }

  void archiveResource(String id) {
    final resource = LibraryRepository.instance.byId(id);
    LibraryRepository.instance.archive(id);
    log('Archived resource "${resource?.title ?? id}"');
  }

  void restoreResource(String id) {
    final resource = LibraryRepository.instance.byId(id);
    LibraryRepository.instance.restore(id);
    log('Restored resource "${resource?.title ?? id}" to approved');
  }

  void deleteResource(String id) {
    final resource = LibraryRepository.instance.byId(id);
    LibraryRepository.instance.remove(id);
    log('Deleted resource "${resource?.title ?? id}"');
  }

  void editResourceMetadata(String id, {String? title, String? subject, String? description}) {
    LibraryRepository.instance.updateMetadata(id, title: title, subject: subject, description: description);
    log('Edited metadata for resource $id');
  }

  Future<void> submitResource(LibraryResource resource) async {
    await LibraryRepository.instance.submitForReview(resource);
    log('Submitted resource "${resource.title}" for review');
  }

  // --- Feed moderation -----------------------------------------------------

  Future<void> publishAnnouncement(String title, String body) async {
    await FeedRepository.instance.publishAnnouncement(title, body);
    NotificationRepository.instance.add(
      type: AppNotificationType.adminAnnouncement,
      title: 'School announcement',
      body: title,
    );
    log('Published announcement "$title"');
  }

  void removePost(String id) {
    final post = FeedRepository.instance.byId(id);
    FeedRepository.instance.adminRemovePost(id);
    log('Removed post "${post?.content.substring(0, post.content.length.clamp(0, 40)) ?? id}" from feed');
  }

  void restorePost(String id) {
    FeedRepository.instance.adminRestorePost(id);
    log('Restored post $id to feed');
  }

  // --- Opportunities -------------------------------------------------------

  Future<void> createOpportunity(Opportunity opportunity) async {
    await OpportunityRepository.instance.create(opportunity);
    log('Created opportunity "${opportunity.title}" (${opportunity.published ? 'published' : 'draft'})');
  }

  void publishOpportunity(String id) {
    final opportunity = OpportunityRepository.instance.byId(id);
    if (opportunity != null && !opportunity.published) {
      OpportunityRepository.instance.togglePublished(id);
      log('Published opportunity "${opportunity.title}"');
    }
  }

  void unpublishOpportunity(String id) {
    final opportunity = OpportunityRepository.instance.byId(id);
    if (opportunity != null && opportunity.published) {
      OpportunityRepository.instance.togglePublished(id);
      log('Unpublished opportunity "${opportunity.title}"');
    }
  }

  void setOpportunityVerified(String id, bool verified) {
    final opportunity = OpportunityRepository.instance.byId(id);
    OpportunityRepository.instance.update(id, verified: verified);
    log('${verified ? 'Verified' : 'Unverified'} opportunity "${opportunity?.title ?? id}"');
  }

  void setOpportunityDeadline(String id, DateTime deadline) {
    final opportunity = OpportunityRepository.instance.byId(id);
    OpportunityRepository.instance.update(id, deadline: deadline);
    log('Updated deadline for "${opportunity?.title ?? id}" to ${deadline.year}-${deadline.month}-${deadline.day}');
  }

  void deleteOpportunity(String id) {
    final opportunity = OpportunityRepository.instance.byId(id);
    OpportunityRepository.instance.remove(id);
    log('Deleted opportunity "${opportunity?.title ?? id}"');
  }

  // --- Users ---------------------------------------------------------------

  DemoStudentAccount? userById(String id) {
    for (final user in users) {
      if (user.id == id) return user;
    }
    return null;
  }

  void suspendUser(String id) {
    final user = userById(id);
    if (user == null) return;
    user.status = AccountStatus.suspended;
    log('Suspended demo account "${user.fullName}" (simulated)');
    notifyListeners();
  }

  void restoreUser(String id) {
    final user = userById(id);
    if (user == null) return;
    user.status = AccountStatus.active;
    log('Restored demo account "${user.fullName}" (simulated)');
    notifyListeners();
  }

  // --- Reports -------------------------------------------------------------

  void resolveReport(String id, String notes) {
    final report = _reportById(id);
    if (report == null) return;
    report.status = ReportStatus.resolved;
    report.notes = notes;
    log('Resolved report $id (${moderationReasonLabel(report.reason)})');
    notifyListeners();
  }

  void dismissReport(String id, String notes) {
    final report = _reportById(id);
    if (report == null) return;
    report.status = ReportStatus.dismissed;
    report.notes = notes;
    log('Dismissed report $id');
    notifyListeners();
  }

  Report? _reportById(String id) {
    for (final report in reports) {
      if (report.id == id) return report;
    }
    return null;
  }

  Report? reportById(String id) => _reportById(id);

  /// Raises a moderation report from any part of the prototype.
  void createReport({
    required ReportTarget target,
    required String targetId,
    required String targetTitle,
    required ModerationReason reason,
    required String reporter,
  }) {
    reports.insert(
      0,
      Report(
        id: 'rp${DateTime.now().millisecondsSinceEpoch}',
        target: target,
        targetId: targetId,
        targetTitle: targetTitle,
        reason: reason,
        reporter: reporter,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  // --- Institutions --------------------------------------------------------

  void addInstitution(String name, InstitutionType type, String location, List<String> programmes) {
    institutions.add(
      Institution(
        id: 'i${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        type: type,
        location: location,
        programmes: programmes,
      ),
    );
    log('Added institution "$name"');
    notifyListeners();
  }

  void removeInstitution(String id) {
    final institution = institutions.where((i) => i.id == id).firstOrNull;
    institutions.removeWhere((i) => i.id == id);
    log('Removed institution "${institution?.name ?? id}"');
    notifyListeners();
  }

  // --- Blocked accounts (from student chats) -------------------------------

  List<String> get blockedAccountNames =>
      ChatRepository.instance.blocked.map((c) => c.peerName).toList();
}
