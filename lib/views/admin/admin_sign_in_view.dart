import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/forms.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../repositories/admin_repository.dart';

/// Separate admin sign-in (its own credentials screen, not a student page).
class AdminSignInView extends StatefulWidget {
  const AdminSignInView({super.key});

  @override
  State<AdminSignInView> createState() => _AdminSignInViewState();
}

class _AdminSignInViewState extends State<AdminSignInView> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController(text: AppConstants.demoAdminEmail);
  final _password = TextEditingController(text: 'admin1234');
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AdminRepository.instance.signIn(email: _email.text, password: _password.text);
    } on ArgumentError catch (e) {
      setState(() => _error = e.message?.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AppLogo(size: 44, showText: false),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Social School',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.teal,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text('ADMIN',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1,
                                        color: Colors.white)),
                              ),
                              const SizedBox(width: 6),
                              const Text('Portal',
                                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  SSCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Administrator sign in',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          const Text(
                            'This area is reserved for Social School administrators.',
                            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            label: 'Admin email',
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.badge_outlined,
                            validator: (v) => (v == null ||
                                        !RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(v.trim()))
                                    ? 'Enter a valid email address'
                                    : null,
                          ),
                          const SizedBox(height: 14),
                          AppPasswordField(
                            controller: _password,
                            validator: (v) =>
                                (v == null || v.length < 6) ? 'Password must be at least 6 characters' : null,
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 8),
                            Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                          ],
                          const SizedBox(height: 16),
                          AppButton(label: 'Sign in to Admin Portal', loading: _loading, onPressed: _submit),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Demo admin credentials: admin@demo.com / admin1234\n'
                      'Unauthorized access is prevented in the demo by this '
                      'separate sign-in (no real security is implied).',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF8A6100), height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'The student app is a separate application. Run it with:\n'
                    'flutter run -d chrome',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
