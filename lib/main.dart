import 'package:flutter/material.dart';

import 'app.dart';
import 'data/demo_state_store.dart';

/// Entry point of the **Social School student app**.
///
/// The admin application lives in a separate project and is not part of
/// this codebase.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Demo-only local storage: restores any saved prototype state so demo
  // changes made before the last relaunch are still there.
  await DemoStateStore.instance.load();
  DemoStateStore.instance.restoreSavedWorld();
  DemoStateStore.instance.attachAutoSave();

  runApp(const SocialSchoolApp());
}
