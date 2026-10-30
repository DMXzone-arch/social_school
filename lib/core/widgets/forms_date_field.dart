import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/formatters.dart';

/// Read-only field that opens a calendar date picker on tap, instead of a
/// keyboard. Shows the picked date formatted (e.g. `14 Mar 2008`).
///
/// Use anywhere a date is chosen (dates of birth, deadlines, event dates).
/// Future integration: this stays UI-only — the picked [value] is passed to
/// a repository/ViewModel which would persist it (e.g. via Supabase).
class AppDateField extends StatelessWidget {
  const AppDateField({
    required this.label,
    required this.onChanged,
    this.value,
    this.hint = 'Select a date',
    this.prefixIcon,
    this.firstDate,
    this.lastDate,
    this.validator,
    super.key,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final String hint;
  final IconData? prefixIcon;
  final DateTime? firstDate;
  final DateTime? lastDate;

  /// Validator returns an error string for the picked date (or null).
  final String? Function(DateTime?)? validator;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final first = firstDate ?? DateTime(now.year - 100, 1, 1);
    final last = lastDate ?? now;
    // Clamp the opening date into [first, last]. Without this, an empty field
    // would open on today's date even when lastDate is in the past (e.g. a
    // date of birth with a minimum-age limit), which trips showDatePicker's
    // initialDate assertion and the calendar never appears.
    var initial = value ?? now;
    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final error = validator?.call(value);
    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _pick(context),
          behavior: HitTestBehavior.opaque,
          child: InputDecorator(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              prefixIcon: prefixIcon == null
                  ? null
                  : Icon(prefixIcon, color: AppColors.textSecondary, size: 20),
              suffixIcon:
                  Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 19),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
              enabledBorder: border(error == null ? AppColors.border : AppColors.error),
              focusedBorder: border(AppColors.primary),
              errorText: error,
            ),
            child: Text(
              value == null ? hint : formatDate(value!),
              style: TextStyle(
                fontSize: 15,
                color: value == null ? AppColors.textSecondary : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
