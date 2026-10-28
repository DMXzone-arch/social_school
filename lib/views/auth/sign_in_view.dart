import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/forms.dart';
import '../../../../core/widgets/ui_kit.dart';
import '../../../../repositories/auth_repository.dart';
import 'widgets/auth_scaffold.dart';

/// Simulated sign-in (any valid-looking demo credentials work).
class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController(text: AppConstants.demoStudentEmail);
  final _password = TextEditingController(text: 'demo1234');
  bool _remember = true;
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
      await AuthRepository.instance.signIn(email: _email.text, password: _password.text);
      if (mounted) {
        showAppSnackbar(context, 'Signed in successfully.');
      }
    } on ArgumentError catch (e) {
      setState(() => _error = e.message?.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthRepository.instance;

    return AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Sign in to continue learning with your school community.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: 'Email address',
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || !RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(v.trim()))
                  ? 'Enter a valid email address'
                  : null,
            ),
            const SizedBox(height: 14),
            AppPasswordField(
              controller: _password,
              validator: (v) =>
                  (v == null || v.length < 6) ? 'Password must be at least 6 characters' : null,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Checkbox(
                  value: _remember,
                  onChanged: (v) => setState(() => _remember = v ?? false),
                  visualDensity: VisualDensity.compact,
                ),
                const Expanded(
                  child: Text('Remember me',
                      overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13)),
                ),
                TextButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: const Text('Forgot password?'),
                      content: const Text(
                        'Enter your email address and we will send you a secure '
                        'link to reset your password.',
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                      ],
                    ),
                  ),
                  child: const Text('Forgot password?', style: TextStyle(fontSize: 12.5)),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 4),
              Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
            ],
            const SizedBox(height: 10),
            AppButton(label: 'Sign In', loading: _loading, onPressed: _submit),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('New here? ', style: TextStyle(fontSize: 13)),
                TextButton(
                  onPressed: auth.goToRegister,
                  child: const Text('Create Account', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
