import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/enums.dart';
import '../models/resource.dart';

/// Simulated digital library and downloads.
///
/// FUTURE BACKEND INTEGRATION POINTS:
/// - Metadata: Supabase table `resources` (replace [resources] with a query).
/// - Files: Cloudflare R2 (or Supabase Storage). Replace [startDownload] with
///   a signed-URL fetch; replace the admin "file selector" with a real upload
///   to the R2 bucket. Keep the same DownloadState flow so the UI is unchanged.
class LibraryRepository extends ChangeNotifier {
  LibraryRepository._();

  static final LibraryRepository instance = LibraryRepository._();

  final List<LibraryResource> resources = List.of(MockData.resources);
  final Map<String, Timer> _downloadTimers = {};

  /// Restores the seeded sample data (admin "Reset demo data").
  void reseed() {
    for (final timer in _downloadTimers.values) {
      timer.cancel();
    }
    _downloadTimers.clear();
    resources
      ..clear()
      ..addAll(MockData.resources);
    notifyListeners();
  }

  /// Resources visible to students (approved only).
  List<LibraryResource> get studentVisible => resources
      .where((resource) => resource.status == ResourceStatus.approved)
      .toList();

  List<LibraryResource> get bookmarks =>
      studentVisible.where((resource) => resource.bookmarked).toList();

  List<LibraryResource> get downloads => studentVisible
      .where((resource) => resource.downloadState == DownloadState.downloaded)
      .toList();

  LibraryResource? byId(String id) {
    for (final resource in resources) {
      if (resource.id == id) return resource;
    }
    return null;
  }

  /// Filtered search used by the student library.
  List<LibraryResource> search({
    String query = '',
    EducationLevel? level,
    ResourceCategory? category,
    String? subject,
    LibraryTab tab = LibraryTab.all,
  }) {
    final normalized = query.trim().toLowerCase();
    return studentVisible.where((resource) {
      if (tab == LibraryTab.bookmarked && !resource.bookmarked) return false;
      if (tab == LibraryTab.downloaded &&
          resource.downloadState != DownloadState.downloaded) {
        return false;
      }
      if (level != null && resource.level != level) return false;
      if (category != null && resource.category != category) return false;
      if (subject != null && resource.subject != subject) return false;
      if (normalized.isEmpty) return true;
      return resource.title.toLowerCase().contains(normalized) ||
          resource.subject.toLowerCase().contains(normalized) ||
          resource.description.toLowerCase().contains(normalized);
    }).toList();
  }

  List<String> get subjectsInLibrary =>
      (studentVisible.map((resource) => resource.subject).toSet().toList()..sort());

  // --- Student actions -----------------------------------------------------

  void toggleBookmark(String id) {
    final resource = byId(id);
    if (resource == null) return;
    resource.bookmarked = !resource.bookmarked;
    notifyListeners();
  }

  /// Simulates a download with progress, success and failure states.
  void startDownload(String id) {
    final resource = byId(id);
    if (resource == null) return;
    _downloadTimers[id]?.cancel();

    resource.downloadState = DownloadState.downloading;
    resource.downloadProgress = 0;
    notifyListeners();

    _downloadTimers[id] = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      if (resource.failNextDownload && resource.downloadProgress > 0.55) {
        timer.cancel();
        _downloadTimers.remove(id);
        resource.downloadState = DownloadState.failed;
        resource.failNextDownload = false; // retry succeeds
        notifyListeners();
        return;
      }

      resource.downloadProgress += 0.09;
      if (resource.downloadProgress >= 1) {
        timer.cancel();
        _downloadTimers.remove(id);
        resource.downloadProgress = 1;
        resource.downloadState = DownloadState.downloaded;
        resource.downloadCount += 1;
        notifyListeners();
        return;
      }
      notifyListeners();
    });
  }

  void removeDownload(String id) {
    _downloadTimers[id]?.cancel();
    _downloadTimers.remove(id);
    final resource = byId(id);
    if (resource == null) return;
    resource.downloadState = DownloadState.none;
    resource.downloadProgress = 0;
    notifyListeners();
  }

  // --- Admin actions -------------------------------------------------------

  /// Submits a new resource for review (admin upload form).
  Future<void> submitForReview(LibraryResource resource) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    resources.insert(0, resource);
    notifyListeners();
  }

  void approve(String id) {
    final resource = byId(id);
    if (resource == null) return;
    resource.status = ResourceStatus.approved;
    resource.rejectionReason = null;
    notifyListeners();
  }

  void reject(String id, String reason) {
    final resource = byId(id);
    if (resource == null) return;
    resource.status = ResourceStatus.rejected;
    resource.rejectionReason = reason;
    notifyListeners();
  }

  void archive(String id) {
    final resource = byId(id);
    if (resource == null) return;
    resource.status = ResourceStatus.archived;
    notifyListeners();
  }

  void restore(String id) {
    final resource = byId(id);
    if (resource == null) return;
    resource.status = ResourceStatus.approved;
    resource.rejectionReason = null;
    notifyListeners();
  }

  void remove(String id) {
    resources.removeWhere((resource) => resource.id == id);
    notifyListeners();
  }

  void updateMetadata(String id, {String? title, String? subject, String? description}) {
    final resource = byId(id);
    if (resource == null) return;
    if (title != null && title.trim().isNotEmpty) resource.title = title.trim();
    if (subject != null && subject.trim().isNotEmpty) resource.subject = subject.trim();
    if (description != null) resource.description = description.trim();
    notifyListeners();
  }
}

/// Tabs on the student library home.
enum LibraryTab { all, bookmarked, downloaded }
