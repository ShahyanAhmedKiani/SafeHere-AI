import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _authService = AuthService();
  final _email = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!_email.text.contains('@')) {
      setState(() => _error = 'Enter a valid email');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _authService.forgotPassword(_email.text.trim());
      if (!mounted) return;
      context.push('/reset-password?email=${Uri.encodeComponent(_email.text.trim())}');
    } catch (e) {
      setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Enter your account email — we'll send a verification code to reset your password.",
                style: TextStyle(color: AppColors.inkSoft),
              ),
              const SizedBox(height: 20),
              ErrorBanner(message: _error),
              AppTextField(controller: _email, label: 'Email', keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 20),
              PrimaryButton(label: 'Send Code', loading: _loading, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
