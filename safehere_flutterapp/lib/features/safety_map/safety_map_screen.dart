import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme.dart';
import '../../models/incident.dart';
import '../../services/incident_service.dart';
import '../../services/location_service.dart';
import '../../services/services_service.dart';

/// Interactive safety map — OSM/CartoDB-style light tiles (via flutter_map),
/// nearby police/hospital/fire markers from the Overpass-backed API, and
/// area safety analysis backed by the backend's incident-scoring endpoint
/// (community-reported incidents, weighted by recency/severity — there's no
/// external crime-data feed wired in, see backend/app/services/safety_intelligence.py).
class SafetyMapScreen extends StatefulWidget {
  const SafetyMapScreen({super.key});

  @override
  State<SafetyMapScreen> createState() => _SafetyMapScreenState();
}

class _SafetyMapScreenState extends State<SafetyMapScreen> {
  final _mapController = MapController();
  final _incidentService = IncidentService();
  LatLng? _me;
  List<NearbyService> _nearby = [];
  List<Incident> _incidents = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final pos = await LocationService.currentPosition();
    if (pos != null) {
      _me = LatLng(pos.latitude, pos.longitude);
      try {
        _nearby = await ServicesService().nearby(pos.latitude, pos.longitude);
      } catch (_) {
        _nearby = [];
      }
      try {
        _incidents = await _incidentService.nearby(pos.latitude, pos.longitude);
      } catch (_) {
        _incidents = [];
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Color _severityColor(String severity) {
    switch (severity) {
      case 'high':
        return AppColors.emergency;
      case 'medium':
        return AppColors.warning;
      default:
        return AppColors.lavender;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'safe':
        return AppColors.safe;
      case 'caution':
        return AppColors.warning;
      default:
        return AppColors.emergency;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'safe':
        return 'Safe';
      case 'caution':
        return 'Caution';
      default:
        return 'High Risk';
    }
  }

  Future<void> _showAreaReport(LatLng point) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => FutureBuilder<SafetyStatus>(
        future: _incidentService.safetyStatus(point.latitude, point.longitude),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox(height: 180, child: Center(child: CircularProgressIndicator()));
          }
          final safety = snapshot.data!;
          final color = _statusColor(safety.status);
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Area Safety Report', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: color.withOpacity(0.15),
                      child: Text('${safety.score}', style: TextStyle(fontWeight: FontWeight.w800, color: color)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_statusLabel(safety.status), style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 16)),
                          const SizedBox(height: 2),
                          Text(safety.reason, style: const TextStyle(color: AppColors.inkSoft, fontSize: 12.5)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _reportIncident(point);
                        },
                        child: const Text('Report Incident'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _reportIncident(LatLng point) async {
    String type = 'other';
    String severity = 'medium';
    final descriptionController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Report an Incident'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(value: 'theft', child: Text('Theft')),
                  DropdownMenuItem(value: 'harassment', child: Text('Harassment')),
                  DropdownMenuItem(value: 'assault', child: Text('Assault')),
                  DropdownMenuItem(value: 'poor_lighting', child: Text('Poor Lighting')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (v) => setDialogState(() => type = v ?? 'other'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: severity,
                decoration: const InputDecoration(labelText: 'Severity'),
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('Low')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'high', child: Text('High')),
                ],
                onChanged: (v) => setDialogState(() => severity = v ?? 'medium'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Submit')),
          ],
        ),
      ),
    );

    if (confirmed != true) return;
    try {
      await _incidentService.report(
        lat: point.latitude,
        lng: point.longitude,
        type: type,
        severity: severity,
        description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thanks — this helps keep the map accurate for everyone.')));
      }
      _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not submit report — check your connection.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = _me ?? const LatLng(33.6844, 73.0479); // Islamabad fallback
    return Scaffold(
      appBar: AppBar(title: const Text('Safety Map')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: 15,
                    onTap: (tapPos, point) => _showAreaReport(point),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                      subdomains: const ['a', 'b', 'c', 'd'],
                      userAgentPackageName: 'ai.safeher.app',
                    ),
                    MarkerLayer(
                      markers: [
                        if (_me != null)
                          Marker(
                            point: _me!,
                            width: 36,
                            height: 36,
                            child: const Icon(Icons.my_location, color: AppColors.rose, size: 28),
                          ),
                        ..._nearby.map((s) => Marker(
                              point: LatLng(s.latitude ?? center.latitude, s.longitude ?? center.longitude),
                              width: 34,
                              height: 34,
                              child: Icon(_iconFor(s.type), color: _serviceColor(s.type)),
                            )),
                        ..._incidents.map((i) => Marker(
                              point: LatLng(i.latitude, i.longitude),
                              width: 26,
                              height: 26,
                              child: Icon(Icons.circle, color: _severityColor(i.severity), size: 16),
                            )),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton.extended(
                    onPressed: () => _me != null ? _showAreaReport(_me!) : null,
                    icon: const Icon(Icons.shield_outlined),
                    label: const Text('Check This Area'),
                  ),
                ),
                Positioned(
                  left: 16,
                  top: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.cardBorder)),
                    child: const Text('Tap the map to check an area\'s safety', style: TextStyle(fontSize: 11, color: AppColors.inkSoft)),
                  ),
                ),
              ],
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

  Color _serviceColor(String type) {
    switch (type) {
      case 'police':
        return Colors.blueAccent;
      case 'hospital':
        return AppColors.emergency;
      case 'fire':
        return AppColors.warning;
      default:
        return AppColors.inkSoft;
    }
  }
}
