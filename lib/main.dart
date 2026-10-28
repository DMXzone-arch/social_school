import 'package:flutter/material.dart';

import 'app.dart';
import 'data/demo_state_store.dart';

/// Entry point of the **Social School student app**.
///
/// The admin application is a completely separate app with its own entry
/// point (`lib/main_admin.dart`) — run it with:
///   flutter run -d chrome -t lib/main_admin.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Demo-only local storage: restores any saved prototype state so changes
  // made in the separate admin app are visible here on relaunch.
  await DemoStateStore.instance.load();
  DemoStateStore.instance.restoreSavedWorld();
  DemoStateStore.instance.attachAutoSave();

  runApp(const SocialSchoolApp());
}
