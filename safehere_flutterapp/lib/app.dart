import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'widgets/app_shell.dart';

import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/auth/forgot_password_screen.dart';
import 'features/auth/reset_password_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/home/home_screen.dart';
import 'features/safety_map/safety_map_screen.dart';
import 'features/journey/journey_screen.dart';
import 'features/journey/active_journey_screen.dart';
import 'features/trusted_circle/trusted_circle_screen.dart';
import 'features/trusted_circle/add_contact_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/emergency/emergency_active_screen.dart';
import 'features/assistant/ai_assistant_screen.dart';
import 'features/fake_call/fake_call_screen.dart';
import 'features/monitor/monitor_screen.dart';
import 'models/journey.dart';

class SafeHerApp extends StatefulWidget {
  const SafeHerApp({super.key});

  @override
  State<SafeHerApp> createState() => _SafeHerAppState();
}

class _SafeHerAppState extends State<SafeHerApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _router = GoRouter(
      initialLocation: '/login',
      refreshListenable: auth,
      redirect: (context, state) {
        final status = auth.status;
        final loggingIn = state.matchedLocation == '/login' ||
            state.matchedLocation == '/register' ||
            state.matchedLocation == '/forgot-password' ||
            state.matchedLocation == '/reset-password';

        if (status == AuthStatus.unknown) return null; // splash-equivalent, wait
        if (status == AuthStatus.unauthenticated && !loggingIn) return '/login';
        if (status == AuthStatus.authenticated && loggingIn) return '/';
        if (status == AuthStatus.authenticated &&
            auth.currentUser != null &&
            !auth.currentUser!.onboardingComplete &&
            state.matchedLocation != '/onboarding') {
          return '/onboarding';
        }
        return null;
      },
      routes: [
        GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
        GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),
        GoRoute(path: '/forgot-password', builder: (c, s) => const ForgotPasswordScreen()),
        GoRoute(path: '/reset-password', builder: (c, s) => ResetPasswordScreen(email: s.uri.queryParameters['email'])),
        GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
        GoRoute(path: '/emergency', builder: (c, s) => const EmergencyActiveScreen()),
        GoRoute(path: '/assistant', builder: (c, s) => const AIAssistantScreen()),
        GoRoute(path: '/fake-call', builder: (c, s) => const FakeCallScreen()),
        GoRoute(path: '/circle/add', builder: (c, s) => const AddContactScreen()),
        GoRoute(path: '/monitor', builder: (c, s) => const MonitorScreen()),
        GoRoute(
          path: '/journey/active',
          builder: (c, s) => ActiveJourneyScreen(journey: s.extra as Journey),
        ),
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(path: '/', builder: (c, s) => const HomeScreen()),
            GoRoute(path: '/map', builder: (c, s) => const SafetyMapScreen()),
            GoRoute(path: '/journey', builder: (c, s) => const JourneyScreen()),
            GoRoute(path: '/circle', builder: (c, s) => const TrustedCircleScreen()),
            GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SafeHer AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}
