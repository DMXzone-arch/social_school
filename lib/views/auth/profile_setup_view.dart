import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/forms.dart';
import '../../../../core/widgets/profile_form_fields.dart';
import '../../../../core/widgets/profile_photo_field.dart';
import '../../../../core/widgets/ui_kit.dart';
import '../../../../data/mock_data.dart';
import '../../../../models/enums.dart';
import '../../../../repositories/auth_repository.dart';
import 'widgets/auth_scaffold.dart';

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
              child: ProfilePhotoField(
                name: AuthRepository.instance.currentUser?.fullName ?? '',
                hasPhoto: _hasPhoto,
                avatarIndex: _avatarIndex,
                onPickPhoto: () => pickProfilePhoto(
                  context,
                  hasPhoto: _hasPhoto,
                  onHasPhotoChanged: (v) => setState(() => _hasPhoto = v),
                ),
                onUseDefaultAvatar: () => setState(() => _hasPhoto = false),
                onAvatarIndexChanged: (i) => setState(() => _avatarIndex = i),
              ),
            ),
            const SizedBox(height: 20),

            // Education level ----------------------------------------------
            const Text('Education level', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            EducationLevelChips(
              selected: _level,
              onChanged: (level) => setState(() {
                _level = level;
                _institution = '';
              }),
            ),
            const SizedBox(height: 16),

            // Location: Malawi district -------------------------------------
            const Text('Location', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const CountryMalawiLabel(),
            const SizedBox(height: 8),
            DistrictField(value: _district, onChanged: (v) => setState(() => _district = v)),
            const SizedBox(height: 16),

            // Date of birth + gender -----------------------------------------
            DateOfBirthField(value: _dateOfBirth, onChanged: (d) => setState(() => _dateOfBirth = d)),
            const SizedBox(height: 14),
            const Text('Gender', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            GenderChips(selected: _gender, onChanged: (g) => setState(() => _gender = g)),
            const SizedBox(height: 16),

            // Institution --------------------------------------------------
            DropdownButtonFormField<String>(
              initialValue: _institutionOptions.contains(_institution) ? _institution : null,
              isExpanded: true,
              decoration: profileDropdownDecoration('Institution (optional)'),
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
            InterestsChips(
              selected: _interests,
              onToggle: (interest) => setState(() {
                _interests.contains(interest) ? _interests.remove(interest) : _interests.add(interest);
              }),
            ),
            const SizedBox(height: 22),

            AppButton(label: 'Complete setup', loading: _saving, onPressed: _submit),
            const SizedBox(height: 6),
            Center(
              child: TextButton(
                onPressed: _complete,
                child: Text('Skip for now — optional fields only',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
