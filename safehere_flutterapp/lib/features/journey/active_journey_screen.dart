import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../models/journey.dart';
import '../../providers/journey_provider.dart';

class ActiveJourneyScreen extends StatelessWidget {
  const ActiveJourneyScreen({super.key, required this.journey});
  final Journey journey;

  Future<void> _confirmEnd(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('End Journey?'),
        content: const Text("This lets your trusted contact know you've arrived safely."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Keep Going')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text("I've Arrived")),
        ],
      ),
    );
    if (confirmed == true) {
      await context.read<JourneyProvider>().endJourney();
      if (context.mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JourneyProvider>(
      builder: (context, provider, _) {
        final live = provider.active ?? journey;
        final deviated = live.isDeviated;

        return PopScope(
          canPop: false,
          child: Scaffold(
            appBar: AppBar(title: const Text('Journey in Progress')),
            body: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: deviated ? AppColors.emergency.withOpacity(0.1) : AppColors.safe.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(deviated ? Icons.warning_rounded : Icons.check_circle, color: deviated ? AppColors.emergency : AppColors.safe),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          deviated ? 'Off planned route — your contact has been alerted.' : 'On track',
                          style: TextStyle(fontWeight: FontWeight.w700, color: deviated ? AppColors.emergency : AppColors.safe),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${live.fromLabel} → ${live.toLabel}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        const SizedBox(height: 12),
                        if (!deviated) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('ETA', style: TextStyle(color: AppColors.inkSoft)),
                              Text(live.etaMinutes != null ? '${live.etaMinutes} min' : '—'),
                            ],
                          ),
                        ] else ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Off-route distance', style: TextStyle(color: AppColors.inkSoft)),
                              Text('${live.offRouteDistanceM.toStringAsFixed(0)} m'),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Route safety', style: TextStyle(color: AppColors.inkSoft)),
                            Text('${live.routeSafetyPercent}%'),
                          ],
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: live.routeSafetyPercent / 100,
                          backgroundColor: AppColors.cardBorder,
                          color: deviated ? AppColors.emergency : AppColors.safe,
                        ),
                        if (live.trustedContactNames.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text('Sharing with ${live.trustedContactNames.join(', ')}', style: const TextStyle(color: AppColors.inkSoft, fontSize: 12.5)),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.safe, padding: const EdgeInsets.symmetric(vertical: 16)),
                    onPressed: () => _confirmEnd(context),
                    child: const Text("I've Arrived — End Journey"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
