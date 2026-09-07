import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
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
  final Set<String> _selectedContactIds = {};
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
        trustedContactIds: _selectedContactIds.toList(),
        notifyOnDeviation: _notifyOnDeviation,
      );
      await journeyProvider.startTracking(journey);
      if (mounted) context.push('/journey/active', extra: journeyProvider.active);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _hexToColor(String hex) => Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16));

  @override
  Widget build(BuildContext context) {
    final contacts = context.watch<ContactsProvider>().contacts;

    return Scaffold(
      appBar: AppBar(title: const Text('Safe Journey')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Plan a journey and share your live location with trusted contacts.', style: TextStyle(color: AppColors.inkSoft)),
          const SizedBox(height: 20),
          AppTextField(controller: _from, label: 'From'),
          const SizedBox(height: 14),
          AppTextField(controller: _to, label: 'To'),
          const SizedBox(height: 20),
          const Text('Share live location with', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Only selected contacts receive this journey\'s updates.', style: TextStyle(color: AppColors.inkSoft, fontSize: 12.5)),
          const SizedBox(height: 10),
          if (contacts.isEmpty)
            TextButton(
              onPressed: () => context.push('/circle/add'),
              child: const Text('No contacts yet — add one'),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: contacts.map((c) {
                final selected = _selectedContactIds.contains(c.id);
                return FilterChip(
                  selected: selected,
                  avatar: CircleAvatar(
                    radius: 10,
                    backgroundColor: _hexToColor(c.avatarColor),
                    child: Text(c.name.isNotEmpty ? c.name[0].toUpperCase() : '?', style: const TextStyle(fontSize: 9, color: Colors.white)),
                  ),
                  label: Text(c.name),
                  selectedColor: AppColors.rose.withOpacity(0.18),
                  checkmarkColor: AppColors.rose,
                  onSelected: (v) => setState(() {
                    if (v) {
                      _selectedContactIds.add(c.id);
                    } else {
                      _selectedContactIds.remove(c.id);
                    }
                  }),
                );
              }).toList(),
            ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Auto-notify on route deviation'),
            value: _notifyOnDeviation,
            onChanged: (v) => setState(() => _notifyOnDeviation = v),
            activeThumbColor: AppColors.rose,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.lavender.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: AppColors.lavender),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'If you trigger SOS during this journey, ALL of your emergency contacts are notified automatically — not just the ones selected above.',
                    style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(label: 'Start Journey', loading: _loading, onPressed: _startJourney),
        ],
      ),
    );
  }
}
