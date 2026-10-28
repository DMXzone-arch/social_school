import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/forms.dart';
import '../../../../core/widgets/ui_kit.dart';
import '../../../../repositories/auth_repository.dart';
import 'widgets/auth_scaffold.dart';

/// Registration form with validation and simulated success.
class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _accepted = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    if (!_accepted) {
      setState(() => _error = 'Please accept the Terms of Use to continue.');
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthRepository.instance.register(
        fullName: _name.text,
        email: _email.text,
        password: _password.text,
        confirmPassword: _confirm.text,
        acceptedTerms: _accepted,
      );
      if (mounted) {
        showAppSnackbar(context, 'Account created successfully.');
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
      title: 'Create your account',
      subtitle: 'Join your school community in a few taps.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: 'Full name',
              hint: 'e.g. Chikondi Banda',
              controller: _name,
              prefixIcon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v == null || v.trim().length < 3) ? 'Enter your full name' : null,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Email address',
              hint: 'you@example.com',
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
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v == null || v.length < 6) ? 'Password must be at least 6 characters' : null,
            ),
            const SizedBox(height: 14),
            AppPasswordField(
              label: 'Confirm password',
              controller: _confirm,
              validator: (v) =>
                  (v != _password.text) ? 'Passwords do not match' : null,
            ),
            const SizedBox(height: 10),
            // Own Material so the checkbox ink isn't hidden by the SSCard
            // background (framework "ListTile background color" warning).
            Material(
              color: Colors.transparent,
              child: CheckboxListTile(
                value: _accepted,
                onChanged: (v) => setState(() => _accepted = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: const Text(
                  'I accept the Terms of Use and Privacy Policy',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 4),
              Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
            ],
            const SizedBox(height: 14),
            AppButton(label: 'Create Account', loading: _loading, onPressed: _submit),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('Already have an account? ', style: TextStyle(fontSize: 13)),
                TextButton(
                  onPressed: auth.goToSignIn,
                  child: const Text('Sign In', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
