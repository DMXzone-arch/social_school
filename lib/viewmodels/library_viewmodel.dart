import 'package:flutter/foundation.dart';

import '../models/enums.dart';
import '../models/resource.dart';
import '../repositories/library_repository.dart';

/// ViewModel for the student library: search, filters and layout state.
class LibraryViewModel extends ChangeNotifier {
  LibraryViewModel() {
    LibraryRepository.instance.addListener(notifyListeners);
  }

  final LibraryRepository _repo = LibraryRepository.instance;

  String _query = '';
  EducationLevel? _level;
  ResourceCategory? _category;
  String? _subject;
  LibraryTab _tab = LibraryTab.all;
  bool _gridLayout = true;

  String get query => _query;
  EducationLevel? get level => _level;
  ResourceCategory? get category => _category;
  String? get subject => _subject;
  LibraryTab get tab => _tab;
  bool get gridLayout => _gridLayout;

  List<LibraryResource> get results => _repo.search(
        query: _query,
        level: _level,
        category: _category,
        subject: _subject,
        tab: _tab,
      );

  List<LibraryResource> get recentlyAdded {
    final list = _repo.studentVisible.toList()
      ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    return list.take(6).toList();
  }

  List<LibraryResource> get popular {
    final list = _repo.studentVisible.toList()
      ..sort((a, b) => b.downloadCount.compareTo(a.downloadCount));
    return list.take(6).toList();
  }

  List<String> get subjects => _repo.subjectsInLibrary;
  int get bookmarkCount => _repo.bookmarks.length;
  int get downloadCount => _repo.downloads.length;

  bool get filtersActive =>
      _query.isNotEmpty || _level != null || _category != null || _subject != null;

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setLevel(EducationLevel? value) {
    _level = _level == value ? null : value;
    notifyListeners();
  }

  void setCategory(ResourceCategory? value) {
    _category = _category == value ? null : value;
    notifyListeners();
  }

  void setSubject(String? value) {
    _subject = value;
    notifyListeners();
  }

  void setTab(LibraryTab value) {
    _tab = value;
    notifyListeners();
  }

  void toggleLayout() {
    _gridLayout = !_gridLayout;
    notifyListeners();
  }

  void clearFilters() {
    _query = '';
    _level = null;
    _category = null;
    _subject = null;
    notifyListeners();
  }

  // Resource actions (delegate to the repository).
  void toggleBookmark(String id) => _repo.toggleBookmark(id);
  void download(String id) => _repo.startDownload(id);
  void removeDownload(String id) => _repo.removeDownload(id);
  LibraryResource? byId(String id) => _repo.byId(id);
}
