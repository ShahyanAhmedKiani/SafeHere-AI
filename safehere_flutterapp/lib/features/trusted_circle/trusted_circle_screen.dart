import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme.dart';
import '../../models/trusted_contact.dart';
import '../../providers/contacts_provider.dart';

class TrustedCircleScreen extends StatefulWidget {
  const TrustedCircleScreen({super.key});

  @override
  State<TrustedCircleScreen> createState() => _TrustedCircleScreenState();
}

class _TrustedCircleScreenState extends State<TrustedCircleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<ContactsProvider>().load());
  }

  Color _hexToColor(String hex) => Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16));

  Future<void> _call(String? phone) async {
    if (phone == null) return;
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _message(String? phone) async {
    if (phone == null) return;
    final uri = Uri(scheme: 'sms', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _remove(TrustedContact contact) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Remove ${contact.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Remove')),
        ],
      ),
    );
    if (confirmed == true) {
      await context.read<ContactsProvider>().remove(contact.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ContactsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trusted Circle'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => context.push('/circle/add')),
        ],
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : provider.contacts.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.people_outline, size: 56, color: AppColors.inkSoft),
                        const SizedBox(height: 12),
                        const Text('No trusted contacts yet.', style: TextStyle(color: AppColors.inkSoft)),
                        const SizedBox(height: 16),
                        FilledButton(onPressed: () => context.push('/circle/add'), child: const Text('Add a contact')),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => context.read<ContactsProvider>().load(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.contacts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final c = provider.contacts[i];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: _hexToColor(c.avatarColor),
                                child: Text(c.name.isNotEmpty ? c.name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                        if (c.isEmergencyContact) ...[
                                          const SizedBox(width: 6),
                                          const Icon(Icons.shield, size: 14, color: AppColors.rose),
                                        ],
                                      ],
                                    ),
                                    Text(c.relationship.isEmpty ? '—' : c.relationship, style: const TextStyle(color: AppColors.inkSoft, fontSize: 12.5)),
                                    Text(
                                      c.status == 'pending' ? 'Not registered — invite to receive alerts' : 'Registered · notifications on',
                                      style: TextStyle(fontSize: 11.5, color: c.status == 'pending' ? AppColors.warning : AppColors.safe),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (v) async {
                                  switch (v) {
                                    case 'call':
                                      _call(c.phone);
                                      break;
                                    case 'message':
                                      _message(c.phone);
                                      break;
                                    case 'invite':
                                      await context.read<ContactsProvider>().invite(c.id);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invitation sent.')));
                                      }
                                      break;
                                    case 'remove':
                                      _remove(c);
                                      break;
                                  }
                                },
                                itemBuilder: (context) => [
                                  if (c.phone != null) const PopupMenuItem(value: 'call', child: Text('Call')),
                                  if (c.phone != null) const PopupMenuItem(value: 'message', child: Text('Message')),
                                  if (c.email != null && c.status == 'pending')
                                    const PopupMenuItem(value: 'invite', child: Text('Invite to SafeHer')),
                                  const PopupMenuItem(value: 'remove', child: Text('Remove')),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
