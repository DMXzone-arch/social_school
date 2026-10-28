import 'enums.dart';

/// A scholarship / internship / programme listing (fictional demo data).
class Opportunity {
  Opportunity({
    required this.id,
    required this.title,
    required this.provider,
    required this.category,
    required this.level,
    required this.eligibility,
    required this.deadline,
    required this.location,
    required this.description,
    required this.requiredDocuments,
    required this.instructions,
    this.remote = false,
    this.verified = false,
    this.published = true,
    this.saved = false,
    this.reportedByMe = false,
  });

  final String id;
  String title;
  String provider;
  OpportunityCategory category;
  EducationLevel level;
  String eligibility;
  DateTime deadline;
  String location;
  String description;
  List<String> requiredDocuments;
  String instructions;
  bool remote;
  bool verified;
  bool published;
  bool saved;
  bool reportedByMe;

  bool get isExpired => deadline.isBefore(DateTime.now());
}
