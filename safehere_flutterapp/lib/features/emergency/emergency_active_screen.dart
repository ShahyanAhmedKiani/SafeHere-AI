import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/emergency_provider.dart';
import '../../services/services_service.dart';

class EmergencyActiveScreen extends StatefulWidget {
  const EmergencyActiveScreen({super.key});

  @override
  State<EmergencyActiveScreen> createState() => _EmergencyActiveScreenState();
}

class _EmergencyActiveScreenState extends State<EmergencyActiveScreen> {
  Timer? _clock;
  Duration _elapsed = Duration.zero;
  List<NearbyService> _nearby = [];
  bool _loadingNearby = false;

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      final started = context.read<EmergencyProvider>().startedAt;
      if (started != null)
        setState(() => _elapsed = DateTime.now().difference(started));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadNearby());
  }

  Future<void> _loadNearby() async {
    final active = context.read<EmergencyProvider>().active;
    if (active?.latitude == null || active?.longitude == null) return;
    setState(() => _loadingNearby = true);
    try {
      _nearby =
          await ServicesService().nearby(active!.latitude!, active.longitude!);
    } catch (_) {
      _nearby = [];
    } finally {
      if (mounted) setState(() => _loadingNearby = false);
    }
  }

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = two(d.inHours);
    final m = two(d.inMinutes % 60);
    final s = two(d.inSeconds % 60);
    return d.inHours > 0 ? '$h:$m:$s' : '$m:$s';
  }

  Future<void> _call(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _shareLocation() async {
    final active = context.read<EmergencyProvider>().active;
    if (active?.latitude == null) return;
    final link =
        'https://www.google.com/maps?q=${active!.latitude},${active.longitude}';
    await Share.share(
      "I need help. My live location: $link",
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Trusted contacts notified: ${active.contactsNotified}')),
      );
    }
  }

  Future<void> _confirmEnd({required bool falseAlarm}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(
            falseAlarm ? 'Mark as False Alarm?' : "I'm Safe — End Emergency?"),
        content: const Text(
            'This will stop live tracking and finalize evidence uploads.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Confirm')),
        ],
      ),
    );
    if (confirmed != true) return;
    await context.read<EmergencyProvider>().resolve(falseAlarm: falseAlarm);
    if (mounted) context.pop();
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emergency = context.watch<EmergencyProvider>();
    final active = emergency.active;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.emergency,
        body: SafeArea(
          child: Column(
            children: [
              _Blinker(
                  text:
                      'EMERGENCY ACTIVE — started ${emergency.startedAt != null ? TimeOfDay.fromDateTime(emergency.startedAt!).format(context) : ''}'),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.ivory,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            children: [
                              _StatusChip(
                                  icon: Icons.timer, label: _fmt(_elapsed)),
                              const SizedBox(width: 10),
                              _StatusChip(
                                  icon: Icons.battery_std,
                                  label: '${active?.batteryLevel ?? '--'}%'),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: _StatusChip(
                                    icon: Icons.location_on, label: 'Live GPS'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Emergency Checklist',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      _ChecklistTile(
                          label: 'GPS acquired',
                          done: active?.latitude != null),
                      _ChecklistTile(
                          label:
                              'Trusted contacts notified (${active?.contactsNotified ?? 0})',
                          done: (active?.contactsNotified ?? 0) > 0),
                      const _ChecklistTile(
                          label: 'Live location sharing', done: true),
                      _ChecklistTile(
                          label: 'Evidence recording',
                          done: active?.evidenceRecording ?? false),
                      const _ChecklistTile(
                          label: 'Emergency protocol active', done: true),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Evidence Upload',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 10),
                              LinearProgressIndicator(
                                value:
                                    (active?.evidenceUploadProgress ?? 0) / 100,
                                backgroundColor: AppColors.cardBorder,
                                color: AppColors.rose,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${active?.evidencePhotos.length ?? 0} photos · ${active?.evidenceVideos.length ?? 0} video clips · ${active?.evidenceClips.length ?? 0} audio clips',
                                style: const TextStyle(
                                    color: AppColors.inkSoft, fontSize: 12.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _call('1122'),
                              icon: const Icon(Icons.call),
                              label: const Text('Call Emergency (1122)'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _shareLocation,
                              icon: const Icon(Icons.ios_share),
                              label: const Text('Share Location'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text('Emergency Services Directory',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: AppConstants.emergencyNumbers.map((n) {
                          return ActionChip(
                            label: Text('${n['name']} · ${n['number']}'),
                            onPressed: () => _call(n['number']!),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Nearby Emergency Services',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          if (_loadingNearby)
                            const SizedBox(
                                height: 14,
                                width: 14,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_nearby.isEmpty && !_loadingNearby)
                        const Text(
                            'No nearby services found — use the national numbers above.',
                            style: TextStyle(color: AppColors.inkSoft)),
                      ..._nearby.take(6).map((s) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading:
                                Icon(_iconFor(s.type), color: AppColors.rose),
                            title: Text(s.name),
                            subtitle: Text(
                                '${s.distanceM ?? '?'} m ${s.direction ?? ''}'),
                            trailing: s.phone != null
                                ? IconButton(
                                    icon: const Icon(Icons.call),
                                    onPressed: () => _call(s.phone!))
                                : null,
                          )),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                              backgroundColor: AppColors.safe,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16)),
                          onPressed: () => _confirmEnd(falseAlarm: false),
                          child: const Text("I'm Safe — End Emergency"),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => _confirmEnd(falseAlarm: true),
                          child: const Text('This was a false alarm'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'police':
        return Icons.local_police;
      case 'hospital':
        return Icons.local_hospital;
      case 'fire':
        return Icons.local_fire_department;
      default:
        return Icons.place;
    }
  }
}

class _Blinker extends StatefulWidget {
  const _Blinker({required this.text});
  final String text;

  @override
  State<_Blinker> createState() => _BlinkerState();
}

class _BlinkerState extends State<_Blinker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.5, end: 1.0).animate(_controller),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Text(
          widget.text,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
          color: AppColors.ivory, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.rose),
          const SizedBox(width: 6),
          Flexible(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({required this.label, required this.done});
  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(done ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 18, color: done ? AppColors.safe : AppColors.inkSoft),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 13.5)),
        ],
      ),
    );
  }
}
