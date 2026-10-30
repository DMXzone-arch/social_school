import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/admin.dart';
import '../models/enums.dart';

/// Collects moderation reports filed by members (report-a-post, report a
/// chat, resource or opportunity). The student app only ever *creates*
/// reports — reviewing them is the job of the separate admin project.
///
/// FUTURE BACKEND INTEGRATION POINT (Supabase):
/// replace [reports] with a query on a `reports` table, protected by row
/// level security so members can only insert rows and read their own.
class ReportRepository extends ChangeNotifier {
  ReportRepository._();

  static final ReportRepository instance = ReportRepository._();

  final List<Report> reports = List.of(MockData.reports);

  /// Raises a moderation report from any part of the student app.
  void createReport({
    required ReportTarget target,
    required String targetId,
    required String targetTitle,
    required ModerationReason reason,
    required String reporter,
  }) {
    reports.insert(
      0,
      Report(
        id: 'rp${DateTime.now().millisecondsSinceEpoch}',
        target: target,
        targetId: targetId,
        targetTitle: targetTitle,
        reason: reason,
        reporter: reporter,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
