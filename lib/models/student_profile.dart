import 'enums.dart';

/// A student account (demo — never a real registered user).
class StudentProfile {
  StudentProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.educationLevel,
    required this.country,
    required this.institution,
    required this.interests,
    this.bio = '',
    this.avatarIndex = kDefaultAvatarIndex,
    this.profileVisible = true,
    this.age,
    this.gender = Gender.preferNotToSay,
    this.district = '',
    this.hasPhoto = false,
  });

  final String id;
  String fullName;
  String email;
  EducationLevel educationLevel;
  String country;
  String institution;
  List<String> interests;
  String bio;

  /// Index into the preset mock avatar colour palette (used when the student
  /// has no uploaded profile photo). [kDefaultAvatarIndex] means "no colour
  /// chosen" and renders the Facebook-style default avatar.
  int avatarIndex;

  bool profileVisible;

  /// Optional personal details collected during profile setup.
  int? age;
  Gender gender;

  /// District/city within [country] (Malawi districts are offered in the picker).
  String district;

  /// Whether the student uploaded a profile photo instead of using a colour
  /// avatar. In this mock a photo is rendered as a gradient placeholder.
  bool hasPhoto;

  /// Whether the student has filled in the optional details (institution).
  bool get hasCompleteDetails => institution.trim().isNotEmpty;

  StudentProfile copy() => StudentProfile(
        id: id,
        fullName: fullName,
        email: email,
        educationLevel: educationLevel,
        country: country,
        institution: institution,
        interests: List.of(interests),
        bio: bio,
        avatarIndex: avatarIndex,
        profileVisible: profileVisible,
        age: age,
        gender: gender,
        district: district,
        hasPhoto: hasPhoto,
      );
}
