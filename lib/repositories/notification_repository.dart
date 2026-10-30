import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/enums.dart';
import '../models/notification_item.dart';

/// Simulated in-app notifications. Nothing is ever pushed or emailed.
///
/// FUTURE BACKEND INTEGRATION POINT (Supabase):
/// a `notifications` table + Supabase push/email extensions.
class NotificationRepository extends ChangeNotifier {
  NotificationRepository._();

  static final NotificationRepository instance = NotificationRepository._();

  final List<AppNotification> items = List.of(MockData.notifications);

  int get unreadCount => items.where((item) => !item.read).length;

  void add({
    required AppNotificationType type,
    required String title,
    required String body,
  }) {
    items.insert(
      0,
      AppNotification(
        id: 'n${DateTime.now().millisecondsSinceEpoch}',
        type: type,
        title: title,
        body: body,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void markRead(String id) {
    for (final item in items) {
      if (item.id == id) item.read = true;
    }
    notifyListeners();
  }

  void markAllRead() {
    for (final item in items) {
      item.read = true;
    }
    notifyListeners();
  }
}
