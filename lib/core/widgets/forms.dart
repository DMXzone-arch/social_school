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
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _pick(context),
          behavior: HitTestBehavior.opaque,
          child: InputDecorator(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              prefixIcon: prefixIcon == null
                  ? null
                  : Icon(prefixIcon, color: AppColors.textSecondary, size: 20),
              suffixIcon:
                  const Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 19),
              filled: true,
              fillColor: AppColors.white,
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

/// Standard filled button with loading state.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
    this.expanded = true,
    this.danger = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final bool expanded;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
              Flexible(
                child: Text(label, overflow: TextOverflow.ellipsis, maxLines: 1),
              ),
            ],
          );

    final button = FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: danger ? AppColors.error : AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
      onPressed: loading ? null : onPressed,
      child: child,
    );

    if (!expanded) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}

/// Outlined secondary button.
class AppOutlinedButton extends StatelessWidget {
  const AppOutlinedButton({
    required this.label,
    this.onPressed,
    this.icon,
    this.expanded = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[Icon(icon, size: 18, color: AppColors.primary), const SizedBox(width: 8)],
        Flexible(
          child: Text(label, overflow: TextOverflow.ellipsis, maxLines: 1),
        ),
      ],
    );

    final button = OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
      onPressed: onPressed,
      child: child,
    );

    if (!expanded) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}

/// Labelled text field used in all forms.
class AppTextField extends StatelessWidget {
  const AppTextField({
    this.label,
    this.hint,
    this.controller,
    this.initialValue,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.textInputAction,
    this.onSubmitted,
    this.prefixIcon,
    this.suffix,
    this.onChanged,
    this.enabled = true,
    this.obscureText = false,
    super.key,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? initialValue;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool enabled;
  final bool obscureText;

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          obscureText: obscureText,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          onChanged: onChanged,
          enabled: enabled,
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, color: AppColors.textSecondary, size: 20),
            suffixIcon: suffix,
            filled: true,
            fillColor: enabled ? AppColors.white : AppColors.background,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            enabledBorder: _border(AppColors.border),
            focusedBorder: _border(AppColors.primary),
            errorBorder: _border(AppColors.error),
            focusedErrorBorder: _border(AppColors.error),
          ),
        ),
      ],
    );
  }
}

/// Password field with visibility toggle.
class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    this.label = 'Password',
    this.hint,
    this.controller,
    this.validator,
    this.textInputAction,
    this.onSubmitted,
    super.key,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      hint: widget.hint,
      controller: widget.controller,
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      obscureText: _obscure,
      keyboardType: TextInputType.visiblePassword,
      suffix: IconButton(
        tooltip: _obscure ? 'Show password' : 'Hide password',
        onPressed: () => setState(() => _obscure = !_obscure),
        icon: Icon(
          _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
          color: AppColors.textSecondary,
          size: 20,
        ),
      ),
    );
  }
}
