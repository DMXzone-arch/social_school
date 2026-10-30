import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Search field used across feed, library and chats.
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    this.controller,
    this.hint = 'Search…',
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    super.key,
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      autofocus: autofocus,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
      ),
    );
  }
}

/// Standard filter/choice chip.
Widget appFilterChip(
  String label, {
  required bool selected,
  VoidCallback? onTap,
  IconData? icon,
}) {
  return ChoiceChip(
    label: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 15, color: selected ? Colors.white : AppColors.textSecondary),
          const SizedBox(width: 5),
        ],
        Text(label),
      ],
    ),
    selected: selected,
    showCheckmark: false,
    onSelected: onTap == null ? null : (_) => onTap(),
    selectedColor: AppColors.primary,
    backgroundColor: AppColors.surface,
    side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
    labelStyle: TextStyle(
      fontSize: 13,
      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      color: selected ? Colors.white : AppColors.textSecondary,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
  );
}
