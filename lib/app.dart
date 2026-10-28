import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'repositories/auth_repository.dart';
import 'viewmodels/chat_viewmodel.dart';
import 'viewmodels/feed_viewmodel.dart';
import 'viewmodels/library_viewmodel.dart';
import 'viewmodels/opportunity_viewmodel.dart';
import 'views/auth/profile_setup_view.dart';
import 'views/auth/register_view.dart';
import 'views/auth/sign_in_view.dart';
import 'views/auth/verify_email_view.dart';
import 'views/auth/welcome_view.dart';
import 'views/student/student_shell.dart';

/// Root widget of the **Social School student app** (consumer users only).
///
/// Routes between the onboarding flow and the student shell based on the
/// simulated authentication state. The admin application lives in a
/// separate app (`lib/main_admin.dart` / `lib/admin_app.dart`) and is not
/// reachable from here.
class SocialSchoolApp extends StatefulWidget {
  const SocialSchoolApp({super.key});

  @override
  State<SocialSchoolApp> createState() => _SocialSchoolAppState();
}

class _SocialSchoolAppState extends State<SocialSchoolApp> {
  /// ViewModels owned by the shell so state survives tab switches.
  late final FeedViewModel feedViewModel = FeedViewModel();
  late final LibraryViewModel libraryViewModel = LibraryViewModel();
  late final ChatViewModel chatViewModel = ChatViewModel();
  late final OpportunityViewModel opportunityViewModel = OpportunityViewModel();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthRepository.instance,
      builder: (context, _) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: _buildHome(),
        );
      },
    );
  }

  Widget _buildHome() {
    return switch (AuthRepository.instance.stage) {
      AuthStage.welcome => const WelcomeView(),
      AuthStage.signIn => const SignInView(),
      AuthStage.register => const RegisterView(),
      AuthStage.verification => const VerifyEmailView(),
      AuthStage.profileSetup => const ProfileSetupView(),
      AuthStage.signedIn => StudentShell(
          feedViewModel: feedViewModel,
          libraryViewModel: libraryViewModel,
          chatViewModel: chatViewModel,
          opportunityViewModel: opportunityViewModel,
        ),
    };
  }
}
