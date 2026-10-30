import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../../models/enums.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'forms.dart';
import 'ui_kit.dart';

/// Interest options offered on profile setup and profile editing.
const List<String> kInterestOptions = [
  'Mathematics', 'Physics', 'Chemistry', 'Biology', 'Computer Science',
  'Business', 'Engineering', 'Debate', 'Sports', 'Music', 'Research', 'Art',
];

/// Shared decoration for the profile forms' district/institution dropdowns.
InputDecoration profileDropdownDecoration(String label) => InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 13, color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.surface,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );

/// Fixed country label — the prototype only operates in Malawi.
class CountryMalawiLabel extends StatelessWidget {
  const CountryMalawiLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return Text('Country: Malawi',
        style: TextStyle(fontSize: 12, color: AppColors.textSecondary));
  }
}

/// Education level chips (single choice).
class EducationLevelChips extends StatelessWidget {
  const EducationLevelChips({required this.selected, required this.onChanged, super.key});

  final EducationLevel selected;
  final ValueChanged<EducationLevel> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        for (final level in EducationLevel.values)
          appFilterChip(
            educationLevelLabel(level),
            selected: selected == level,
            onTap: () => onChanged(level),
          ),
      ],
    );
  }
}

/// Malawi district dropdown (expanded so long district names always fit).
class DistrictField extends StatelessWidget {
  const DistrictField({required this.value, required this.onChanged, super.key});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value.isEmpty ? null : value,
      isExpanded: true,
      decoration: profileDropdownDecoration('District'),
      items: [
        for (final district in AppConstants.malawiDistricts)
          DropdownMenuItem(value: district, child: Text(district, overflow: TextOverflow.ellipsis)),
      ],
      onChanged: (v) => onChanged(v ?? ''),
    );
  }
}

/// Date of birth picker with the derived "Age N" hint and the 10–100 age
/// validation used by both profile forms.
class DateOfBirthField extends StatelessWidget {
  const DateOfBirthField({required this.value, required this.onChanged, super.key});

  final DateTime? value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppDateField(
          label: 'Date of birth',
          value: value,
          prefixIcon: Icons.cake_outlined,
          hint: 'Select your date of birth',
          firstDate: DateTime(DateTime.now().year - 100, 1, 1),
          lastDate: dateOfBirthForAge(10), // ages below 10 aren't allowed
          onChanged: onChanged,
          validator: (d) {
            if (d == null) return null; // optional
            final age = ageFromDateOfBirth(d);
            return (age < 10 || age > 100) ? 'Enter a date giving an age between 10 and 100' : null;
          },
        ),
        if (value != null) ...[
          const SizedBox(height: 6),
          Text('Age ${ageFromDateOfBirth(value!)}',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ],
    );
  }
}

/// Gender chips (single choice).
class GenderChips extends StatelessWidget {
  const GenderChips({required this.selected, required this.onChanged, super.key});

  final Gender selected;
  final ValueChanged<Gender> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        for (final gender in Gender.values)
          appFilterChip(
            genderLabel(gender),
            selected: selected == gender,
            onTap: () => onChanged(gender),
          ),
      ],
    );
  }
}

/// Multi-select interest chips drawn from [kInterestOptions].
class InterestsChips extends StatelessWidget {
  const InterestsChips({required this.selected, required this.onToggle, super.key});

  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final interest in kInterestOptions)
          appFilterChip(
            interest,
            selected: selected.contains(interest),
            onTap: () => onToggle(interest),
          ),
      ],
    );
  }
}
