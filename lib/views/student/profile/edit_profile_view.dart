import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/forms.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../core/widgets/responsive.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../models/enums.dart';
import '../../../repositories/auth_repository.dart';

const List<String> _interestOptions = [
  'Mathematics', 'Physics', 'Chemistry', 'Biology', 'Computer Science',
  'Business', 'Engineering', 'Debate', 'Sports', 'Music', 'Research', 'Art',
];

/// Edit the signed-in demo student's profile.
class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _bio;
  late final TextEditingController _institution;
  late EducationLevel _level;
  late String _district;
  late DateTime? _dateOfBirth;
  late Gender _gender;
  late bool _hasPhoto;
  late int _avatarIndex;
  late final Set<String> _interests;

  @override
  void initState() {
    super.initState();
    final me = AuthRepository.instance.currentUser!;
    _name = TextEditingController(text: me.fullName);
    _bio = TextEditingController(text: me.bio);
    _institution = TextEditingController(text: me.institution);
    _level = me.educationLevel;
    _district = me.district;
    _dateOfBirth = me.age == null ? null : dateOfBirthForAge(me.age!);
    _gender = me.gender;
    _hasPhoto = me.hasPhoto;
    _avatarIndex = me.avatarIndex;
    _interests = Set.of(me.interests);
  }

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    _institution.dispose();
    super.dispose();
  }

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

  int? get _age => _dateOfBirth == null ? null : ageFromDateOfBirth(_dateOfBirth!);

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final updated = AuthRepository.instance.currentUser!.copy()
      ..fullName = _name.text.trim()
      ..bio = _bio.text.trim()
      ..institution = _institution.text.trim()
      ..educationLevel = _level
      ..country = 'Malawi'
      ..district = _district.trim()
      ..age = _age
      ..gender = _gender
      ..hasPhoto = _hasPhoto
      ..avatarIndex = _avatarIndex
      ..interests = _interests.toList();
    AuthRepository.instance.updateProfile(updated);
    Navigator.of(context).pop();
    showAppSnackbar(context, 'Profile updated.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: CenteredContent(
        maxWidth: 640,
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SSCard(
                child: Column(
                  children: [
                    ProfileAvatar(
                      name: _name.text.trim().isEmpty
                          ? (AuthRepository.instance.currentUser?.fullName ?? '')
                          : _name.text.trim(),
                      avatarIndex: _avatarIndex,
                      hasPhoto: _hasPhoto,
                      radius: 34,
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
              const SizedBox(height: 14),
              SSCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      label: 'Full name',
                      controller: _name,
                      validator: (v) =>
                          (v == null || v.trim().length < 3) ? 'Enter your full name' : null,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Bio',
                      hint: 'A short intro for classmates…',
                      controller: _bio,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final level in EducationLevel.values)
                          appFilterChip(
                            educationLevelLabel(level),
                            selected: _level == level,
                            onTap: () => setState(() => _level = level),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text('Country: Malawi',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _district.isEmpty ? null : _district,
                      isExpanded: true,
                      decoration: _dropdownDecoration('District'),
                      items: [
                        for (final district in AppConstants.malawiDistricts)
                          DropdownMenuItem(
                              value: district, child: Text(district, overflow: TextOverflow.ellipsis)),
                      ],
                      onChanged: (v) => setState(() => _district = v ?? ''),
                    ),
                    const SizedBox(height: 14),
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
                        return (age < 10 || age > 100)
                            ? 'Enter a date giving an age between 10 and 100'
                            : null;
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
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Institution',
                      hint: 'e.g. Kambiri University',
                      controller: _institution,
                      prefixIcon: Icons.school_outlined,
                    ),
                    const SizedBox(height: 16),
                    const Text('Interests', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
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
                              _interests.contains(interest)
                                  ? _interests.remove(interest)
                                  : _interests.add(interest);
                            }),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppButton(label: 'Save changes', onPressed: _save),
              const SizedBox(height: 40),
            ],
          ),
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
