import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/forms.dart';
import '../../../../repositories/auth_repository.dart';
import 'widgets/auth_scaffold.dart';

/// Welcome screen: branding, value proposition and entry points.
class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthRepository.instance;

    return AuthScaffold(
      title: AppConstants.appName,
      subtitle: AppConstants.tagline,
      maxWidth: 520,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppConstants.description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
          ),
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: const [
              _FeatureChip(icon: Icons.forum_rounded, label: 'Connect'),
              _FeatureChip(icon: Icons.campaign_rounded, label: 'School updates'),
              _FeatureChip(icon: Icons.menu_book_rounded, label: 'Free books'),
            ],
          ),
          const SizedBox(height: 22),
          AppButton(label: 'Create Account', icon: Icons.person_add_alt_1_rounded, onPressed: auth.goToRegister),
          const SizedBox(height: 10),
          AppOutlinedButton(label: 'Sign In', icon: Icons.login_rounded, onPressed: auth.goToSignIn),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => _showPolicyDialog(context, 'Terms of Use'),
                child: const Text('Terms of Use', style: TextStyle(fontSize: 12.5)),
              ),
              Text('·', style: TextStyle(color: AppColors.textSecondary)),
              TextButton(
                onPressed: () => _showPolicyDialog(context, 'Privacy Policy'),
                child: const Text('Privacy Policy', style: TextStyle(fontSize: 12.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPolicyDialog(BuildContext context, String title) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: SizedBox(
          width: 420,
          child: Text(
            'Welcome to Social School. By using the app you agree to our '
            'commitment to a safe, respectful community for members.\n\n'
            'We protect your privacy, moderate content, and keep your '
            'personal data secure.',
            style: const TextStyle(height: 1.5),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.teal),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.teal)),
        ],
      ),
    );
  }
}
