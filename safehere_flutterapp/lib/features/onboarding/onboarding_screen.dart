import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;
  bool _loading = false;

  static const _pages = [
    _OnboardPage(
      icon: Icons.shield,
      title: "You're Protected",
      body: 'One tap activates AI-driven monitoring, live location sharing, and automatic '
          'evidence capture whenever you need it.',
    ),
    _OnboardPage(
      icon: Icons.people_alt,
      title: 'Build Your Trusted Circle',
      body: 'Add the people who should know when something feels wrong — they get notified '
          'automatically during an emergency or a deviated journey.',
    ),
    _OnboardPage(
      icon: Icons.map,
      title: 'See the Safety Map',
      body: 'Risk zones, nearby police and hospitals, and safer-route suggestions — all in one '
          'calm, easy view.',
    ),
  ];

  Future<void> _finish() async {
    setState(() => _loading = true);
    await context.read<AuthProvider>().updateProfile({'onboarding_complete': true});
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _index = i),
                children: _pages,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _index ? 22 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _index ? AppColors.rose : AppColors.cardBorder,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: isLast ? 'Get Started' : 'Next',
                    loading: _loading,
                    onPressed: isLast
                        ? _finish
                        : () => _controller.nextPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                            ),
                  ),
                  if (!isLast)
                    TextButton(onPressed: _loading ? null : _finish, child: const Text('Skip')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  const _OnboardPage({required this.icon, required this.title, required this.body});
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(color: AppColors.rose.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(icon, size: 44, color: AppColors.rose),
          ),
          const SizedBox(height: 28),
          Text(title, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(body, style: const TextStyle(color: AppColors.inkSoft, height: 1.5), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
