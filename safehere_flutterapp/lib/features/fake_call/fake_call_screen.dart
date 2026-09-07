import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Simulated incoming call, used to gracefully exit an uncomfortable situation.
class FakeCallScreen extends StatefulWidget {
  const FakeCallScreen({super.key});

  @override
  State<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen> {
  bool _connected = false;
  Timer? _durationTimer;
  Timer? _ringTimer;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startRinging();
  }

  void _startRinging() {
    // Flutter's built-in haptic feedback (no native plugin needed) pulses
    // every 1.2s to simulate an incoming-call buzz.
    _ringTimer = Timer.periodic(const Duration(milliseconds: 1200), (_) {
      HapticFeedback.heavyImpact();
    });
  }

  void _answer() {
    _ringTimer?.cancel();
    setState(() => _connected = true);
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _duration += const Duration(seconds: 1));
    });
  }

  void _end() {
    _ringTimer?.cancel();
    _durationTimer?.cancel();
    context.pop();
  }

  @override
  void dispose() {
    _ringTimer?.cancel();
    _durationTimer?.cancel();
    super.dispose();
  }

  String _fmt(Duration d) => '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF1B1723),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 24),
                const CircleAvatar(radius: 56, backgroundColor: Colors.white24, child: Icon(Icons.person, size: 56, color: Colors.white)),
                const SizedBox(height: 20),
                const Text('Mom', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(
                  _connected ? _fmt(_duration) : 'Incoming call…',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const Spacer(),
                if (!_connected)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _CallButton(icon: Icons.call_end, color: Colors.redAccent, onTap: _end),
                      _CallButton(icon: Icons.call, color: Colors.greenAccent.shade400, onTap: _answer),
                    ],
                  )
                else
                  _CallButton(icon: Icons.call_end, color: Colors.redAccent, onTap: _end),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  const _CallButton({required this.icon, required this.color, required this.onTap});
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }
}
