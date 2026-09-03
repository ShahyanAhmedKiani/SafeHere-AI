import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../models/emergency_event.dart';
import '../../providers/monitor_provider.dart';

/// Web/desktop-oriented operations view for guardians & response teams —
/// same Flutter codebase runs here on mobile too, with a tabbed fallback for
/// narrow screens (list / map / detail) instead of the three-pane desktop layout.
class MonitorScreen extends StatefulWidget {
  const MonitorScreen({super.key});

  @override
  State<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen> {
  EmergencyEvent? _selected;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MonitorProvider>();
      provider.load();
      provider.connectRealtime();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MonitorProvider>();
    final active = provider.events.where((e) => e.status == 'active').toList();
    final resolvedToday = provider.events.where((e) => e.status != 'active').length;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Monitor Dashboard'),
          bottom: const TabBar(tabs: [Tab(text: 'Alerts'), Tab(text: 'Map'), Tab(text: 'Detail')]),
        ),
        body: provider.loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _AlertsTab(
                    events: provider.events,
                    activeCount: active.length,
                    resolvedCount: resolvedToday,
                    onSelect: (e) => setState(() => _selected = e),
                  ),
                  _MapTab(events: active),
                  _DetailTab(
                    event: _selected,
                    onStatus: (status) {
                      if (_selected != null) provider.setStatus(_selected!.id, status);
                    },
                  ),
                ],
              ),
      ),
    );
  }
}

class _AlertsTab extends StatelessWidget {
  const _AlertsTab({required this.events, required this.activeCount, required this.resolvedCount, required this.onSelect});
  final List<EmergencyEvent> events;
  final int activeCount;
  final int resolvedCount;
  final void Function(EmergencyEvent) onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(child: _StatCard(label: 'Active Alerts', value: '$activeCount', color: AppColors.emergency)),
              const SizedBox(width: 10),
              Expanded(child: _StatCard(label: 'Resolved', value: '$resolvedCount', color: AppColors.safe)),
            ],
          ),
        ),
        Expanded(
          child: events.isEmpty
              ? const Center(child: Text('No emergency events yet.', style: TextStyle(color: AppColors.inkSoft)))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: events.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final e = events[i];
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          e.status == 'active' ? Icons.warning_rounded : Icons.check_circle,
                          color: e.status == 'active' ? AppColors.emergency : AppColors.safe,
                        ),
                        title: Text(e.type.toUpperCase()),
                        subtitle: Text('${e.status} · started ${e.startedAt}'),
                        onTap: () {
                          onSelect(e);
                          DefaultTabController.of(context).animateTo(2);
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: const TextStyle(color: AppColors.inkSoft, fontSize: 12.5)),
        ],
      ),
    );
  }
}

class _MapTab extends StatelessWidget {
  const _MapTab({required this.events});
  final List<EmergencyEvent> events;

  @override
  Widget build(BuildContext context) {
    final withLocation = events.where((e) => e.latitude != null && e.longitude != null).toList();
    final center = withLocation.isNotEmpty
        ? LatLng(withLocation.first.latitude!, withLocation.first.longitude!)
        : const LatLng(33.6844, 73.0479);

    return FlutterMap(
      options: MapOptions(initialCenter: center, initialZoom: 12),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'ai.safeher.app',
        ),
        MarkerLayer(
          markers: withLocation
              .map((e) => Marker(
                    point: LatLng(e.latitude!, e.longitude!),
                    width: 36,
                    height: 36,
                    child: const Icon(Icons.warning_rounded, color: AppColors.emergency, size: 30),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _DetailTab extends StatelessWidget {
  const _DetailTab({required this.event, required this.onStatus});
  final EmergencyEvent? event;
  final void Function(String status) onStatus;

  @override
  Widget build(BuildContext context) {
    if (event == null) {
      return const Center(child: Text('Select an alert from the Alerts tab.', style: TextStyle(color: AppColors.inkSoft)));
    }
    final e = event!;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('${e.type.toUpperCase()} · ${e.status}', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        _row('Started', e.startedAt),
        _row('Resolved', e.resolvedAt ?? '—'),
        _row('Battery', e.batteryLevel != null ? '${e.batteryLevel}%' : '—'),
        _row('Contacts notified', '${e.contactsNotified}'),
        _row('Evidence', '${e.evidencePhotos.length} photos · ${e.evidenceVideos.length} videos · ${e.evidenceClips.length} audio'),
        if (e.latitude != null) _row('Location', '${e.latitude!.toStringAsFixed(5)}, ${e.longitude!.toStringAsFixed(5)}'),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.safe),
              onPressed: e.status == 'active' ? () => onStatus('resolved') : null,
              child: const Text('Mark Resolved'),
            ),
            OutlinedButton(
              onPressed: e.status == 'active' ? () => onStatus('false_alarm') : null,
              child: const Text('False Alarm'),
            ),
            OutlinedButton(
              onPressed: e.status == 'active' ? () => onStatus('cancelled') : null,
              child: const Text('Cancel'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.inkSoft)),
          Flexible(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}
