import 'package:flutter/material.dart';

import '../core/theme.dart';

class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.emergency.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message!, style: const TextStyle(color: AppColors.emergency)),
    );
  }
}
