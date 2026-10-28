import 'enums.dart';

/// A moderation report raised in the prototype.
class Report {
  Report({
    required this.id,
    required this.target,
    required this.targetId,
    required this.targetTitle,
    required this.reason,
    required this.reporter,
    required this.timestamp,
    this.status = ReportStatus.open,
    this.notes = '',
  });

  final String id;
  final ReportTarget target;
  final String targetId;
  final String targetTitle;
  final ModerationReason reason;
  final String reporter;
  final DateTime timestamp;
  ReportStatus status;
  String notes;
}

/// A simulated administrator action for the audit log.
class AuditEntry {
  AuditEntry({
    required this.id,
    required this.adminName,
    required this.action,
    required this.timestamp,
  });

  final String id;
  final String adminName;
  final String action;
  final DateTime timestamp;
}

/// Fictional demo student account used in admin user management.
class DemoStudentAccount {
  DemoStudentAccount({
    required this.id,
    required this.fullName,
    required this.email,
    required this.level,
    required this.institution,
    required this.registered,
    this.status = AccountStatus.active,
  });

  final String id;
  final String fullName;
  final String email;
  final EducationLevel level;
  final String institution;
  final DateTime registered;
  AccountStatus status;
}

/// A mock institution entry.
class Institution {
  Institution({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    List<String>? programmes,
  }) : programmes = programmes ?? <String>[];

  final String id;
  String name;
  InstitutionType type;
  String location;
  final List<String> programmes;

  bool levelMatches(EducationLevel level) => switch (level) {
        EducationLevel.secondary => type == InstitutionType.secondary,
        EducationLevel.college => type == InstitutionType.college,
        EducationLevel.university => type == InstitutionType.university,
      };
}
