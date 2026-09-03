import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../models/trusted_contact.dart';
import '../../providers/contacts_provider.dart';
import '../../providers/journey_provider.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

class JourneyScreen extends StatefulWidget {
  const JourneyScreen({super.key});

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  final _from = TextEditingController(text: 'Current location');
  final _to = TextEditingController();
  TrustedContact? _selectedContact;
  bool _notifyOnDeviation = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<ContactsProvider>().load());
  }

  Future<void> _startJourney() async {
    if (_to.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a destination.')));
      return;
    }
    setState(() => _loading = true);
    try {
      final journeyProvider = context.read<JourneyProvider>();
      final journey = await journeyProvider.create(
        fromLabel: _from.text.trim(),
        toLabel: _to.text.trim(),
        trustedContactId: _selectedContact?.id,
        notifyOnDeviation: _notifyOnDeviation,
      );
      await journeyProvider.startTracking(journey);
      if (mounted) context.push('/journey/active', extra: journeyProvider.active);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contacts = context.watch<ContactsProvider>().contacts;

    return Scaffold(
      appBar: AppBar(title: const Text('Safe Journey')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Plan a journey and share it with a trusted contact.', style: TextStyle(color: AppColors.inkSoft)),
          const SizedBox(height: 20),
          AppTextField(controller: _from, label: 'From'),
          const SizedBox(height: 14),
          AppTextField(controller: _to, label: 'To'),
          const SizedBox(height: 14),
          DropdownButtonFormField<TrustedContact>(
            initialValue: _selectedContact,
            decoration: const InputDecoration(labelText: 'Notify trusted contact'),
            items: contacts
                .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                .toList(),
            onChanged: (c) => setState(() => _selectedContact = c),
          ),
          if (contacts.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: TextButton(
                onPressed: () => context.push('/circle/add'),
                child: const Text('No contacts yet — add one'),
              ),
            ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Auto-notify on route deviation'),
            value: _notifyOnDeviation,
            onChanged: (v) => setState(() => _notifyOnDeviation = v),
            activeThumbColor: AppColors.rose,
          ),
          const SizedBox(height: 20),
          PrimaryButton(label: 'Start Journey', loading: _loading, onPressed: _startJourney),
        ],
      ),
    );
  }
}
