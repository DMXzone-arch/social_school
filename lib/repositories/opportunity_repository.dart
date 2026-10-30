import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/enums.dart';
import '../models/opportunity.dart';

/// Simulated scholarships & opportunities listings.
///
/// FUTURE BACKEND INTEGRATION POINT (Supabase):
/// an `opportunities` table with an `expires_at` column; a scheduled job
/// (Supabase cron) can mark listings expired, matching [Opportunity.isExpired].
class OpportunityRepository extends ChangeNotifier {
  OpportunityRepository._();

  static final OpportunityRepository instance = OpportunityRepository._();

  final List<Opportunity> opportunities = List.of(MockData.opportunities);

  /// Listings members can browse (published only).
  List<Opportunity> get published =>
      opportunities.where((o) => o.published).toList();

  List<Opportunity> get saved =>
      published.where((o) => o.saved).toList();

  Opportunity? byId(String id) {
    for (final opportunity in opportunities) {
      if (opportunity.id == id) return opportunity;
    }
    return null;
  }

  List<Opportunity> search({
    String query = '',
    OpportunityCategory? category,
    EducationLevel? level,
    String? location,
    bool savedOnly = false,
    bool includeExpired = true,
  }) {
    final normalized = query.trim().toLowerCase();
    return published.where((opportunity) {
      if (savedOnly && !opportunity.saved) return false;
      if (!includeExpired && opportunity.isExpired) return false;
      if (category != null && opportunity.category != category) return false;
      if (level != null && opportunity.level != level) return false;
      if (location != null && opportunity.location != location) return false;
      if (normalized.isEmpty) return true;
      return opportunity.title.toLowerCase().contains(normalized) ||
          opportunity.provider.toLowerCase().contains(normalized) ||
          opportunity.eligibility.toLowerCase().contains(normalized);
    }).toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  List<String> get locations =>
      (published.map((o) => o.location).toSet().toList()..sort());

  void toggleSave(String id) {
    final opportunity = byId(id);
    if (opportunity == null) return;
    opportunity.saved = !opportunity.saved;
    notifyListeners();
  }

  void markReported(String id) {
    final opportunity = byId(id);
    if (opportunity != null) opportunity.reportedByMe = true;
    notifyListeners();
  }
}
