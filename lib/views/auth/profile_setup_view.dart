import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/forms.dart';
import '../../../../core/widgets/profile_avatar.dart';
import '../../../../core/widgets/ui_kit.dart';
import '../../../../data/mock_data.dart';
import '../../../../models/enums.dart';
import '../../../../repositories/auth_repository.dart';
import 'widgets/auth_scaffold.dart';

const List<String> _interestOptions = [
  'Mathematics', 'Physics', 'Chemistry', 'Biology', 'Computer Science',
  'Business', 'Engineering', 'Debate', 'Sports', 'Music', 'Research', 'Art',
];

/// Profile setup: profile photo (or colour avatar), education level, location
/// (Malawi districts), date of birth, gender, institution and interests.
///
/// Uploading a profile picture is the primary option; the Facebook-style
/// default avatar (or a chosen colour) is only used if the student prefers
/// not to upload a photo. All optional fields can be skipped and edited later
/// in Settings.
class ProfileSetupView extends StatefulWidget {
  const ProfileSetupView({super.key});

  @override
  State<ProfileSetupView> createState() => _ProfileSetupViewState();
}

class _ProfileSetupViewState extends State<ProfileSetupView> {
  final _formKey = GlobalKey<FormState>();

  bool _hasPhoto = false;
  int _avatarIndex = kDefaultAvatarIndex;
  EducationLevel _level = EducationLevel.secondary;
  String _district = '';
  DateTime? _dateOfBirth;
  Gender _gender = Gender.preferNotToSay;
  String _institution = '';
  final Set<String> _interests = {};
  bool _saving = false;

  List<String> get _institutionOptions => MockData.institutions
      .where((i) => i.levelMatches(_level))
      .map((i) => i.name)
      .toList();

  int? get _age => _dateOfBirth == null ? null : ageFromDateOfBirth(_dateOfBirth!);

  Future<void> _pickPhoto() async {
    final choice = await showProfilePhotoSheet(context, hasPhoto: _hasPhoto);
    if (!mounted) return;
    switch (choice) {
      case PhotoSheetChoice.camera:
      case PhotoSheetChoice.gallery:
        setState(() => _hasPhoto = true);
      case PhotoSheetChoice.remove:
        setState(() => _hasPhoto = false);
      case PhotoSheetChoice.cancel:
        break;
    }
  }

  Future<void> _complete() async {
    setState(() => _saving = true);
    await AuthRepository.instance.completeProfileSetup(
      level: _level,
      district: _district,
      institution: _institution,
      interests: _interests.toList(),
      avatarIndex: _avatarIndex,
      age: _age,
      gender: _gender,
      hasPhoto: _hasPhoto,
    );
    if (mounted) {
      showAppSnackbar(context, 'Profile set up. Welcome to Social School!');
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) _complete();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Set up your profile',
      subtitle: 'Tell us a little about yourself — you can edit this later.',
      maxWidth: 560,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile photo / avatar ----------------------------------------
            Center(
              child: Column(
                children: [
                  ProfileAvatar(
                    name: AuthRepository.instance.currentUser?.fullName ?? '',
                    avatarIndex: _avatarIndex,
                    hasPhoto: _hasPhoto,
                    radius: 38,
                  ),
                  const SizedBox(height: 12),
                  // Photo actions stacked vertically so the labels always fit.
                  AppButton(
                    label: _hasPhoto ? 'Change photo' : 'Upload photo',
                    icon: Icons.photo_camera_outlined,
                    onPressed: _pickPhoto,
                  ),
                  const SizedBox(height: 10),
                  AppOutlinedButton(
                    label: 'Use default avatar',
                    icon: Icons.person_outline,
                    onPressed: () => setState(() => _hasPhoto = false),
                  ),
                  if (!_hasPhoto) ...[
                    const SizedBox(height: 12),
                    const Text('Or pick an avatar colour',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        // Facebook-style default avatar (no colour).
                        GestureDetector(
                          onTap: () => setState(() => _avatarIndex = kDefaultAvatarIndex),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.avatarPlaceholderBackground,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _avatarIndex == kDefaultAvatarIndex
                                    ? AppColors.textPrimary
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                            child: const Icon(Icons.person,
                                size: 18, color: AppColors.avatarPlaceholderForeground),
                          ),
                        ),
                        for (var i = 0; i < AppColors.avatarPalette.length; i++)
                          GestureDetector(
                            onTap: () => setState(() => _avatarIndex = i),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.avatarPalette[i],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _avatarIndex == i ? AppColors.textPrimary : Colors.transparent,
                                  width: 2.5,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Education level ----------------------------------------------
            const Text('Education level', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final level in EducationLevel.values)
                  appFilterChip(
                    educationLevelLabel(level),
                    selected: _level == level,
                    onTap: () => setState(() {
                      _level = level;
                      _institution = '';
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Location: Malawi district -------------------------------------
            const Text('Location', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Country: Malawi',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _district.isEmpty ? null : _district,
              isExpanded: true,
              decoration: _dropdownDecoration('District'),
              items: [
                for (final district in AppConstants.malawiDistricts)
                  DropdownMenuItem(value: district, child: Text(district, overflow: TextOverflow.ellipsis)),
              ],
              onChanged: (v) => setState(() => _district = v ?? ''),
            ),
            const SizedBox(height: 16),

            // Date of birth + gender -----------------------------------------
            AppDateField(
              label: 'Date of birth',
              value: _dateOfBirth,
              prefixIcon: Icons.cake_outlined,
              hint: 'Select your date of birth',
              firstDate: DateTime(DateTime.now().year - 100, 1, 1),
              lastDate: dateOfBirthForAge(10), // ages below 10 aren't allowed
              onChanged: (d) => setState(() => _dateOfBirth = d),
              validator: (d) {
                if (d == null) return null; // optional
                final age = ageFromDateOfBirth(d);
                return (age < 10 || age > 100) ? 'Enter a date giving an age between 10 and 100' : null;
              },
            ),
            if (_dateOfBirth != null) ...[
              const SizedBox(height: 6),
              Text('Age ${ageFromDateOfBirth(_dateOfBirth!)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
            const SizedBox(height: 14),
            const Text('Gender', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final gender in Gender.values)
                  appFilterChip(
                    genderLabel(gender),
                    selected: _gender == gender,
                    onTap: () => setState(() => _gender = gender),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Institution --------------------------------------------------
            DropdownButtonFormField<String>(
              initialValue: _institutionOptions.contains(_institution) ? _institution : null,
              isExpanded: true,
              decoration: _dropdownDecoration('Institution (optional)'),
              items: [
                for (final name in _institutionOptions)
                  DropdownMenuItem(value: name, child: Text(name, overflow: TextOverflow.ellipsis)),
              ],
              onChanged: (v) => setState(() => _institution = v ?? ''),
            ),
            const SizedBox(height: 6),
            AppTextField(
              label: 'Or type your institution',
              hint: 'Leave empty if not listed',
              initialValue: _institution,
              onChanged: (v) => _institution = v.trim(),
            ),
            const SizedBox(height: 16),

            // Interests ----------------------------------------------------
            const Text('Interests (optional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final interest in _interestOptions)
                  appFilterChip(
                    interest,
                    selected: _interests.contains(interest),
                    onTap: () => setState(() {
                      _interests.contains(interest) ? _interests.remove(interest) : _interests.add(interest);
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 22),

            AppButton(label: 'Complete setup', loading: _saving, onPressed: _submit),
            const SizedBox(height: 6),
            Center(
              child: TextButton(
                onPressed: _complete,
                child: const Text('Skip for now — optional fields only',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      );
}
