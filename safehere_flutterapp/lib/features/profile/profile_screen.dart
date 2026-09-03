import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _name = TextEditingController(text: user?.fullName ?? '');
    _phone = TextEditingController(text: user?.phone ?? '');
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await context.read<AuthProvider>().updateProfile({
        'full_name': _name.text.trim(),
        'phone': _phone.text.trim(),
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated.')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.rose,
              child: Text(
                (user?.fullName.isNotEmpty ?? false) ? user!.fullName[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(child: Text(user?.email ?? '', style: const TextStyle(color: AppColors.inkSoft))),
          const SizedBox(height: 24),
          AppTextField(controller: _name, label: 'Full name'),
          const SizedBox(height: 14),
          AppTextField(controller: _phone, label: 'Phone', keyboardType: TextInputType.phone),
          const SizedBox(height: 20),
          PrimaryButton(label: 'Save Changes', loading: _saving, onPressed: _save),
          const SizedBox(height: 28),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shield_outlined, color: AppColors.rose),
            title: const Text('Monitor Dashboard'),
            subtitle: const Text('For guardians and response teams'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/monitor'),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.emergency),
            title: const Text('Sign Out', style: TextStyle(color: AppColors.emergency)),
            onTap: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
    );
  }
}
