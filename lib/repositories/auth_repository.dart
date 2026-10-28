import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/enums.dart';
import '../models/student_profile.dart';

/// Stages of the simulated authentication/onboarding flow.
enum AuthStage { welcome, signIn, register, verification, profileSetup, signedIn }

/// Simulated authentication.
///
/// FUTURE BACKEND INTEGRATION POINT (Supabase Auth):
/// replace `register`, `signIn` and `signOut` with calls to
/// `Supabase.instance.client.auth` and map the session user onto
/// [StudentProfile]. The UI does not need to change.
class AuthRepository extends ChangeNotifier {
  AuthRepository._();

  static final AuthRepository instance = AuthRepository._();

  AuthStage stage = AuthStage.signIn;
  StudentProfile? currentUser;

  /// Profile collected during registration, awaiting setup completion.
  StudentProfile? _pendingProfile;

  /// Email captured during registration (shown on the verification screen).
  String? get pendingEmail => _pendingProfile?.email;

  /// Simulated account: any valid-looking credentials work.
  bool get isDemoAccount => currentUser?.email == MockData.demoStudent.email;

  final Map<String, bool> notificationPrefs = {
    'Comments and reactions': true,
    'Conversation requests': true,
    'Admin announcements': true,
    'Scholarship reminders': true,
  };

  // --- Navigation between onboarding stages -------------------------------

  void goToSignIn() {
    stage = AuthStage.signIn;
    notifyListeners();
  }

  void goToRegister() {
    stage = AuthStage.register;
    notifyListeners();
  }

  void goBackToWelcome() {
    stage = AuthStage.welcome;
    notifyListeners();
  }

  // --- Simulated registration --------------------------------------------

  /// Validates and "creates" a demo account. Throws [ArgumentError] with a
  /// user-facing message on invalid input.
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
    required bool acceptedTerms,
  }) async {
    final name = fullName.trim();
    if (name.length < 3) throw ArgumentError('Please enter your full name.');
    if (!_isEmail(email)) throw ArgumentError('Please enter a valid email address.');
    if (password.length < 6) {
      throw ArgumentError('Password must be at least 6 characters.');
    }
    if (password != confirmPassword) throw ArgumentError('Passwords do not match.');
    if (!acceptedTerms) {
      throw ArgumentError('Please accept the Terms of Use to continue.');
    }

    await _simulateLatency();

    _pendingProfile = StudentProfile(
      id: 'me',
      fullName: name,
      email: email.trim(),
      educationLevel: EducationLevel.secondary,
      country: 'Malawi',
      institution: '',
      interests: [],
    );
    stage = AuthStage.verification;
    notifyListeners();
  }

  void resendVerification() {
    // Simulated — no email is ever sent.
    stage = AuthStage.verification;
    notifyListeners();
  }

  void continueAfterVerification() {
    stage = AuthStage.profileSetup;
    notifyListeners();
  }

  /// Completes profile setup after registration.
  ///
  /// Country is always Malawi in this prototype; no form/year-of-study is
  /// collected.
  Future<void> completeProfileSetup({
    required EducationLevel level,
    required String institution,
    required List<String> interests,
    required int avatarIndex,
    int? age,
    Gender gender = Gender.preferNotToSay,
    String district = '',
    bool hasPhoto = false,
  }) async {
    await _simulateLatency(short: true);

    final profile = _pendingProfile ?? MockData.demoStudent.copy();
    profile
      ..educationLevel = level
      ..country = 'Malawi'
      ..district = district.trim()
      ..institution = institution.trim()
      ..interests = List.of(interests)
      ..age = age
      ..gender = gender
      ..hasPhoto = hasPhoto
      ..avatarIndex = avatarIndex;
    currentUser = profile;
    _pendingProfile = null;
    stage = AuthStage.signedIn;
    notifyListeners();
  }

  // --- Simulated sign-in ---------------------------------------------------

  /// Simulated sign-in: any valid-looking email + password (6+ chars) works.
  Future<void> signIn({required String email, required String password}) async {
    if (!_isEmail(email)) throw ArgumentError('Please enter a valid email address.');
    if (password.length < 6) throw ArgumentError('Password must be at least 6 characters.');

    await _simulateLatency();

    currentUser = MockData.demoStudent.copy();
    currentUser!.email = email.trim();
    stage = AuthStage.signedIn;
    notifyListeners();
  }

  void signOut() {
    currentUser = null;
    stage = AuthStage.signIn;
    notifyListeners();
  }

  // --- Profile -------------------------------------------------------------

  void updateProfile(StudentProfile updated) {
    currentUser = updated;
    notifyListeners();
  }

  void setNotificationPref(String key, bool value) {
    notificationPrefs[key] = value;
    notifyListeners();
  }

  void setProfileVisibility(bool visible) {
    currentUser?.profileVisible = visible;
    notifyListeners();
  }

  // --- Helpers -------------------------------------------------------------

  static bool _isEmail(String value) =>
      RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(value.trim());

  static Future<void> _simulateLatency({bool short = false}) =>
      Future<void>.delayed(Duration(milliseconds: short ? 350 : 700));
}
