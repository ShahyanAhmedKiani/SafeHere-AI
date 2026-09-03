import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(_name.text.trim(), _email.text.trim(), _password.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (!ok) {
      setState(() => _error = auth.lastError ?? 'Something went wrong.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Join SafeHer AI',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                const Text('Your safety companion, always with you.', style: TextStyle(color: AppColors.inkSoft)),
                const SizedBox(height: 24),
                ErrorBanner(message: _error),
                AppTextField(
                  controller: _name,
                  label: 'Full name',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _email,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _password,
                  label: 'Password',
                  obscureText: true,
                  validator: (v) => (v == null || v.length < 8) ? 'At least 8 characters' : null,
                ),
                const SizedBox(height: 20),
                PrimaryButton(label: 'Create Account', loading: _loading, onPressed: _submit),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?', style: TextStyle(color: AppColors.inkSoft)),
                    TextButton(onPressed: () => context.pop(), child: const Text('Sign in')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
