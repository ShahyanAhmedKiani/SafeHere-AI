import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/contacts_provider.dart';
import '../../services/api_client.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/primary_button.dart';

class AddContactScreen extends StatefulWidget {
  const AddContactScreen({super.key});

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _relationship = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<ContactsProvider>().add(
            name: _name.text.trim(),
            relationship: _relationship.text.trim(),
            phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
            email: _email.text.trim().isEmpty ? null : _email.text.trim(),
          );
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Trusted Contact')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ErrorBanner(message: _error),
              AppTextField(
                controller: _name,
                label: 'Name',
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
              ),
              const SizedBox(height: 14),
              AppTextField(controller: _relationship, label: 'Relationship (e.g. Mother, Friend)'),
              const SizedBox(height: 14),
              AppTextField(controller: _phone, label: 'Phone', keyboardType: TextInputType.phone),
              const SizedBox(height: 14),
              AppTextField(controller: _email, label: 'Email (needed for alerts)', keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 20),
              PrimaryButton(label: 'Save Contact', loading: _loading, onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
