import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

import '../../../core/constants.dart';
import '../../../core/theme.dart';

/// Press-and-hold SOS activation with a circular progress ring, matching the
/// spec's 1.6s hold-to-confirm gesture (prevents accidental activation).
class SosButton extends StatefulWidget {
  const SosButton({super.key, required this.onActivated});
  final VoidCallback onActivated;

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppConstants.sosHoldDurationMs),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && !_triggered) {
          _triggered = true;
          _fireHaptic();
          widget.onActivated();
        }
      });
  }

  Future<void> _fireHaptic() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 200);
    }
  }

  void _onHoldStart() {
    _triggered = false;
    _controller.forward(from: 0);
  }

  void _onHoldEnd() {
    if (!_triggered) _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _onHoldStart(),
      onLongPressEnd: (_) => _onHoldEnd(),
      onLongPressCancel: _onHoldEnd,
      child: SizedBox(
        width: 168,
        height: 168,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 168,
                  height: 168,
                  child: CircularProgressIndicator(
                    value: _controller.value,
                    strokeWidth: 6,
                    backgroundColor: AppColors.emergency.withOpacity(0.15),
                    valueColor: const AlwaysStoppedAnimation(AppColors.emergency),
                  ),
                ),
                Container(
                  width: 132,
                  height: 132,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.emergency, AppColors.roseDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(color: AppColors.emergency.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning_rounded, color: Colors.white, size: 32),
                      SizedBox(height: 6),
                      Text('HOLD FOR SOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
