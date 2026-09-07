import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/contacts_provider.dart';
import '../../providers/emergency_provider.dart';
import 'widgets/quick_action.dart';
import 'widgets/safety_score_ring.dart';
import 'widgets/sos_button.dart';
import 'widgets/trusted_circle_preview.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContactsProvider>().load();
    });
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    if (hour < 21) return 'Good evening';
    return 'Good night';
  }

  Future<void> _activateSos() async {
    final emergency = context.read<EmergencyProvider>();
    await emergency.activate();
    if (mounted) context.push('/emergency');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final contacts = context.watch<ContactsProvider>();
    final name = auth.currentUser?.fullName.split(' ').first ?? '';

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => context.read<ContactsProvider>().load(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text('${_greeting()}, $name',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                ),
                Stack(
                  children: [
                    IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
                    const Positioned(
                      right: 10,
                      top: 10,
                      child: CircleAvatar(radius: 4, backgroundColor: AppColors.emergency),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _HeroStatusCard(),
            const SizedBox(height: 20),
            Center(
              child: SosButton(onActivated: _activateSos),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                QuickAction(icon: Icons.warning_amber_rounded, label: 'SOS', color: AppColors.emergency, onTap: _activateSos),
                QuickAction(icon: Icons.route, label: 'Journey', onTap: () => context.go('/journey')),
                QuickAction(icon: Icons.ios_share, label: 'Share', onTap: () => _quickShareLocation(context)),
              ],
            ),
            const SizedBox(height: 24),
            _AiSafetyMonitorCard(onTap: () => context.go('/map')),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Trusted Circle', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                TextButton(onPressed: () => context.go('/circle'), child: const Text('See all')),
              ],
            ),
            TrustedCirclePreview(contacts: contacts.contacts),
            const SizedBox(height: 20),
            _AssistantEntryCard(onTap: () => context.push('/assistant')),
          ],
        ),
      ),
    );
  }

  void _quickShareLocation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Open the Safety Map to share your live location with a contact.')),
    );
  }
}

class _HeroStatusCard extends StatelessWidget {
  const _HeroStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.rose, AppColors.lavender]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), shape: BoxShape.circle),
            child: const Icon(Icons.shield, color: Colors.white),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("You're Protected", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
                SizedBox(height: 2),
                Text('AI monitoring active', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AiSafetyMonitorCard extends StatelessWidget {
  const _AiSafetyMonitorCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              const SafetyScoreRing(score: 86, size: 60),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI Safety Monitor', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    SizedBox(height: 4),
                    Text(
                      "You're in a well-lit area with regular foot traffic. No unusual activity detected.",
                      style: TextStyle(color: AppColors.inkSoft, fontSize: 12.5, height: 1.4),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.inkSoft),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssistantEntryCard extends StatelessWidget {
  const _AssistantEntryCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: AppColors.lavender.withOpacity(0.15), shape: BoxShape.circle),
                child: const Icon(Icons.auto_awesome, color: AppColors.lavender),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text('Ask your AI Safety Assistant anything', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              const Icon(Icons.chevron_right, color: AppColors.inkSoft),
            ],
          ),
        ),
      ),
    );
  }
}
