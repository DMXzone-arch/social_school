/// Date/time formatting helpers.
library;

const List<String> _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// e.g. `28 Oct 2026`
String formatDate(DateTime date) =>
    '${date.day} ${_months[date.month - 1]} ${date.year}';

/// e.g. `14:05`
String formatTime(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

/// e.g. `28 Oct 2026, 14:05`
String formatDateTime(DateTime date) => '${formatDate(date)}, ${formatTime(date)}';

/// Human friendly relative time, e.g. `5m ago`, `3h ago`, `2d ago`.
String timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return formatDate(date);
}

/// Days until [date]; negative when it has passed.
int daysUntil(DateTime date) => date.difference(DateTime.now()).inDays;

/// Whole years between [dateOfBirth] and today.
int ageFromDateOfBirth(DateTime dateOfBirth) {
  final today = DateTime.now();
  var age = today.year - dateOfBirth.year;
  final hadBirthdayThisYear = today.month > dateOfBirth.month ||
      (today.month == dateOfBirth.month && today.day >= dateOfBirth.day);
  if (!hadBirthdayThisYear) age--;
  return age;
}

/// A birthday exactly [years] ago today — used to seed date pickers
/// (e.g. defaulting an age back into a date of birth).
DateTime dateOfBirthForAge(int years, {DateTime? from}) {
  final ref = from ?? DateTime.now();
  return DateTime(ref.year - years, ref.month, ref.day);
}
