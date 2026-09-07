import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/primary_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, this.email});
  final String? email;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _authService = AuthService();
  late final TextEditingController _email = TextEditingController(text: widget.email ?? '');
  final _code = TextEditingController();
  final _newPassword = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _done = false;

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _authService.resetPassword(
        email: _email.text.trim(),
        code: _code.text.trim(),
        newPassword: _newPassword.text,
      );
      setState(() => _done = true);
    } catch (e) {
      setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _done
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.safe, size: 56),
                    const SizedBox(height: 12),
                    const Text('Password updated. You can now sign in.', textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    PrimaryButton(label: 'Back to Sign In', onPressed: () => context.go('/login')),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Enter the code we emailed you, then set a new password.',
                        style: TextStyle(color: AppColors.inkSoft)),
                    const SizedBox(height: 20),
                    ErrorBanner(message: _error),
                    AppTextField(controller: _email, label: 'Email', keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 14),
                    AppTextField(controller: _code, label: 'Verification code', keyboardType: TextInputType.number),
                    const SizedBox(height: 14),
                    AppTextField(controller: _newPassword, label: 'New password', obscureText: true),
                    const SizedBox(height: 20),
                    PrimaryButton(label: 'Reset Password', loading: _loading, onPressed: _submit),
                  ],
                ),
        ),
      ),
    );
  }
}
