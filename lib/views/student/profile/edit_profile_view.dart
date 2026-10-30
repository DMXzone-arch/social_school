import 'package:flutter/material.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/forms.dart';
import '../../../core/widgets/profile_form_fields.dart';
import '../../../core/widgets/profile_photo_field.dart';
import '../../../core/widgets/responsive.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../models/enums.dart';
import '../../../repositories/auth_repository.dart';

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
                child: ProfilePhotoField(
                  name: _name.text.trim().isEmpty
                      ? (AuthRepository.instance.currentUser?.fullName ?? '')
                      : _name.text.trim(),
                  hasPhoto: _hasPhoto,
                  avatarIndex: _avatarIndex,
                  radius: 34,
                  onPickPhoto: () => pickProfilePhoto(
                    context,
                    hasPhoto: _hasPhoto,
                    onHasPhotoChanged: (v) => setState(() => _hasPhoto = v),
                  ),
                  onUseDefaultAvatar: () => setState(() => _hasPhoto = false),
                  onAvatarIndexChanged: (i) => setState(() => _avatarIndex = i),
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
                    EducationLevelChips(selected: _level, onChanged: (l) => setState(() => _level = l)),
                    const SizedBox(height: 14),
                    const CountryMalawiLabel(),
                    const SizedBox(height: 14),
                    DistrictField(value: _district, onChanged: (v) => setState(() => _district = v)),
                    const SizedBox(height: 14),
                    DateOfBirthField(
                        value: _dateOfBirth, onChanged: (d) => setState(() => _dateOfBirth = d)),
                    const SizedBox(height: 14),
                    const Text('Gender', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    GenderChips(selected: _gender, onChanged: (g) => setState(() => _gender = g)),
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
                    InterestsChips(
                      selected: _interests,
                      onToggle: (interest) => setState(() {
                        _interests.contains(interest)
                            ? _interests.remove(interest)
                            : _interests.add(interest);
                      }),
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
}
