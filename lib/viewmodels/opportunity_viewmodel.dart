import 'package:flutter/foundation.dart';

import '../models/enums.dart';
import '../models/opportunity.dart';
import '../repositories/opportunity_repository.dart';

/// ViewModel for the student opportunities section.
class OpportunityViewModel extends ChangeNotifier {
  OpportunityViewModel() {
    OpportunityRepository.instance.addListener(notifyListeners);
  }

  final OpportunityRepository _repo = OpportunityRepository.instance;

  String _query = '';
  OpportunityCategory? _category;
  EducationLevel? _level;
  String? _location;
  bool _savedOnly = false;
  bool _hideExpired = false;

  String get query => _query;
  OpportunityCategory? get category => _category;
  EducationLevel? get level => _level;
  String? get location => _location;
  bool get savedOnly => _savedOnly;
  bool get hideExpired => _hideExpired;

  bool get filtersActive =>
      _category != null || _level != null || _location != null || _query.isNotEmpty;

  List<Opportunity> get results => _repo.search(
        query: _query,
        category: _category,
        level: _level,
        location: _location,
        savedOnly: _savedOnly,
        includeExpired: !_hideExpired,
      );

  List<String> get locations => _repo.locations;
  int get savedCount => _repo.saved.length;

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setCategory(OpportunityCategory? value) {
    _category = _category == value ? null : value;
    notifyListeners();
  }

  void setLevel(EducationLevel? value) {
    _level = _level == value ? null : value;
    notifyListeners();
  }

  void setLocation(String? value) {
    _location = value;
    notifyListeners();
  }

  void toggleSavedOnly() {
    _savedOnly = !_savedOnly;
    notifyListeners();
  }

  void toggleHideExpired() {
    _hideExpired = !_hideExpired;
    notifyListeners();
  }

  void clearFilters() {
    _query = '';
    _category = null;
    _level = null;
    _location = null;
    notifyListeners();
  }

  void toggleSave(String id) => _repo.toggleSave(id);
  List<Opportunity> get savedList => _repo.saved;
}
