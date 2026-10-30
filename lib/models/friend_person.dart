/// A person in the friends system: an incoming request, a suggestion or an
/// existing friend.
///
/// Lightweight by design — the friends feature only needs identity plus the
/// institution shown in subtitles.
class FriendPerson {
  const FriendPerson({
    required this.id,
    required this.name,
    required this.institution,
    this.subtitle = '',
  });

  final String id;
  final String name;
  final String institution;

  /// Extra line shown under the institution (e.g. "3 mutual friends").
  final String subtitle;
}
