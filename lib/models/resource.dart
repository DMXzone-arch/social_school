import 'enums.dart';

/// A study resource in the digital library (sample file — no real uploads).
class LibraryResource {
  LibraryResource({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.level,
    required this.institution,
    required this.category,
    required this.author,
    required this.fileType,
    required this.fileSize,
    required this.fileSizeMb,
    required this.dateAdded,
    required this.status,
    this.submittedBy = 'Demo uploader',
    this.downloadCount = 0,
    this.rejectionReason,
    this.bookmarked = false,
    this.downloadState = DownloadState.none,
    this.failNextDownload = false,
  });

  final String id;
  String title;
  String description;
  String subject;
  EducationLevel level;
  String institution;
  ResourceCategory category;
  String author;
  final String fileType;
  final String fileSize;
  final double fileSizeMb;
  final DateTime dateAdded;
  ResourceStatus status;
  String submittedBy;
  String? rejectionReason;

  int downloadCount;

  // Client-side interaction state (prototype only).
  bool bookmarked;
  DownloadState downloadState;
  double downloadProgress = 0;

  /// Simulates a one-time download failure for demo purposes.
  bool failNextDownload;

  LibraryResource copy() => LibraryResource(
        id: id,
        title: title,
        description: description,
        subject: subject,
        level: level,
        institution: institution,
        category: category,
        author: author,
        fileType: fileType,
        fileSize: fileSize,
        fileSizeMb: fileSizeMb,
        dateAdded: dateAdded,
        status: status,
        submittedBy: submittedBy,
        downloadCount: downloadCount,
        rejectionReason: rejectionReason,
        bookmarked: bookmarked,
        downloadState: downloadState,
        failNextDownload: failNextDownload,
      );
}
