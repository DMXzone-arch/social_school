/// Shared enumerations for the Social School prototype.
library;

/// Sentinel avatar index meaning "no colour chosen": renders the
/// Facebook-style default avatar (grey circle + person silhouette) instead of
/// coloured initials.
const int kDefaultAvatarIndex = -1;

enum EducationLevel { secondary, college, university }

String educationLevelLabel(EducationLevel level) => switch (level) {
      EducationLevel.secondary => 'Secondary School',
      EducationLevel.college => 'College',
      EducationLevel.university => 'University',
    };

enum Gender { male, female, other, preferNotToSay }

String genderLabel(Gender gender) => switch (gender) {
      Gender.male => 'Male',
      Gender.female => 'Female',
      Gender.other => 'Other',
      Gender.preferNotToSay => 'Prefer not to say',
    };

enum PostType { studentPost, schoolAnnouncement, adminAnnouncement }

String postTypeLabel(PostType type) => switch (type) {
      PostType.studentPost => 'Member post',
      PostType.schoolAnnouncement => 'School announcement',
      PostType.adminAnnouncement => 'Admin announcement',
    };

enum ResourceCategory {
  textbooks,
  lectureNotes,
  revisionNotes,
  pastPapers,
  studyGuides,
  practicalGuides,
  generalAcademic,
}

String resourceCategoryLabel(ResourceCategory category) => switch (category) {
      ResourceCategory.textbooks => 'Textbooks',
      ResourceCategory.lectureNotes => 'Lecture Notes',
      ResourceCategory.revisionNotes => 'Revision Notes',
      ResourceCategory.pastPapers => 'Past Examination Papers',
      ResourceCategory.studyGuides => 'Study Guides',
      ResourceCategory.practicalGuides => 'Practical & Lab Guides',
      ResourceCategory.generalAcademic => 'General Academic',
    };

enum ResourceStatus { draft, pendingReview, approved, rejected, archived }

String resourceStatusLabel(ResourceStatus status) => switch (status) {
      ResourceStatus.draft => 'Draft',
      ResourceStatus.pendingReview => 'Pending Review',
      ResourceStatus.approved => 'Approved',
      ResourceStatus.rejected => 'Rejected',
      ResourceStatus.archived => 'Archived',
    };

enum DownloadState { none, downloading, downloaded, failed }

enum OpportunityCategory {
  scholarship,
  internship,
  competition,
  training,
  conference,
  youthProgramme,
}

String opportunityCategoryLabel(OpportunityCategory category) => switch (category) {
      OpportunityCategory.scholarship => 'Scholarship',
      OpportunityCategory.internship => 'Internship',
      OpportunityCategory.competition => 'Competition',
      OpportunityCategory.training => 'Training Programme',
      OpportunityCategory.conference => 'Academic Conference',
      OpportunityCategory.youthProgramme => 'Youth Programme',
    };

enum ModerationReason {
  inappropriate,
  unauthorisedMaterials,
  spam,
  harassment,
  suspiciousOpportunity,
}

String moderationReasonLabel(ModerationReason reason) => switch (reason) {
      ModerationReason.inappropriate => 'Inappropriate content',
      ModerationReason.unauthorisedMaterials => 'Unauthorised learning materials',
      ModerationReason.spam => 'Spam',
      ModerationReason.harassment => 'Harassment',
      ModerationReason.suspiciousOpportunity => 'Suspicious opportunity listing',
    };

enum ReportTarget { post, resource, opportunity, user }

enum ReportStatus { open, resolved, dismissed }

enum InstitutionType { secondary, college, university }

String institutionTypeLabel(InstitutionType type) => switch (type) {
      InstitutionType.secondary => 'Secondary School',
      InstitutionType.college => 'College',
      InstitutionType.university => 'University',
    };

enum AppNotificationType { request, accepted, comment, reaction, adminAnnouncement, scholarship }

/// All sample content across the prototype is fictional.
const String kDemoContentNote = 'Fictional demo content.';
