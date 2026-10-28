import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'repositories/admin_repository.dart';
import 'views/admin/admin_shell.dart';
import 'views/admin/admin_sign_in_view.dart';

/// Root widget of the **Social School Admin application**.
///
/// This is a separate app from the student application: it has its own
/// entry point (`lib/main_admin.dart`), its own sign-in screen and its own
/// navigation shell. It never shows student surfaces.
class SocialSchoolAdminApp extends StatelessWidget {
  const SocialSchoolAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminRepository.instance,
      builder: (context, _) {
        return MaterialApp(
          title: '${AppConstants.appName} Admin',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: AdminRepository.instance.signedIn
              ? const AdminShell()
              : const AdminSignInView(),
        );
      },
    );
  }
}
