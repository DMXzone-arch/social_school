import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/forms.dart';
import '../../../../core/widgets/ui_kit.dart';
import '../../../../repositories/auth_repository.dart';
import 'widgets/auth_scaffold.dart';

/// Simulated email verification — clearly labelled as demo behaviour.
class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  bool _resent = false;

  @override
  Widget build(BuildContext context) {
    final auth = AuthRepository.instance;
    final email = auth.pendingEmail;

    return AuthScaffold(
      title: 'Verify your email',
      subtitle: 'Almost there — one quick verification step.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              border: Border.all(color: AppColors.gold),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.mail_lock_outlined, color: Color(0xFF8A6100)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'We sent a verification link to your email address. '
                    'Open it to verify your account.',
                    style: TextStyle(fontSize: 12.5, color: Color(0xFF8A6100), height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Icon(Icons.mark_email_read_outlined, size: 52, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            email == null
                ? 'We would send a verification link to your email address.'
                : 'We would send a verification link to\n$email',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 20),
          AppButton(label: 'Continue (skip verification)', onPressed: auth.continueAfterVerification),
          const SizedBox(height: 10),
          AppOutlinedButton(
            label: _resent ? 'Verification re-sent' : 'Resend verification',
            icon: Icons.refresh_rounded,
            onPressed: () {
              auth.resendVerification();
              setState(() => _resent = true);
              showAppSnackbar(context, 'Verification email re-sent.');
            },
          ),
        ],
      ),
    );
  }
}
