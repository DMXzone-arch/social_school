import 'package:flutter/material.dart';

import 'admin_app.dart';
import 'data/demo_state_store.dart';

/// Entry point of the **Social School Admin app** (separate from the
/// student app — see `lib/main.dart`).
///
/// Run it with:
///   flutter run -d chrome -t lib/main_admin.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Demo-only local storage so admin changes (approvals, announcements,
  // listings) are visible in the student app after it relaunches.
  await DemoStateStore.instance.load();
  DemoStateStore.instance.restoreSavedWorld();
  DemoStateStore.instance.attachAutoSave();

  runApp(const SocialSchoolAdminApp());
}
