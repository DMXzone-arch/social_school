import 'enums.dart';

/// A simulated in-app notification (never actually sent anywhere).
class AppNotification {
  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    this.read = false,
  });

  final String id;
  final AppNotificationType type;
  final String title;
  final String body;
  final DateTime timestamp;
  bool read;
}
