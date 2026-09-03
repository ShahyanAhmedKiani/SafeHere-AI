import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../models/emergency_event.dart';
import '../services/battery_service.dart';
import '../services/emergency_service.dart';
import '../services/evidence_capture_service.dart';
import '../services/location_service.dart';

class EmergencyProvider extends ChangeNotifier {
  final _service = EmergencyService();

  EmergencyEvent? active;
  EvidenceCaptureService? _capture;
  Timer? _locationTimer;
  DateTime? startedAt;
  final List<String> captureLog = [];

  bool get isActive => active != null && active!.isActive;

  Future<void> activate() async {
    final position = await LocationService.currentPosition();
    final battery = await BatteryService.level();

    active = await _service.activate(
      type: 'sos',
      latitude: position?.latitude,
      longitude: position?.longitude,
      batteryLevel: battery,
    );
    startedAt = DateTime.now();
    notifyListeners();

    _locationTimer = Timer.periodic(
      const Duration(seconds: AppConstants.gpsLogIntervalSeconds),
      (_) => _pushLocation(),
    );

    _capture = EvidenceCaptureService(
      active!.id,
      _service,
      onLog: (msg) {
        captureLog.add(msg);
        notifyListeners();
      },
    );
    unawaited(_capture!.start());
  }

  Future<void> _pushLocation() async {
    if (active == null) return;
    final position = await LocationService.currentPosition();
    if (position == null) return;
    final battery = await BatteryService.level();
    try {
      active = await _service.updateLocation(active!.id, position.latitude, position.longitude, battery: battery);
      notifyListeners();
    } catch (_) {
      // transient network issue — retried on the next tick.
    }
  }

  Future<void> resolve({required bool falseAlarm}) async {
    if (active == null) return;
    _locationTimer?.cancel();
    await _capture?.stop();
    active = await _service.setStatus(active!.id, falseAlarm ? 'false_alarm' : 'resolved');
    notifyListeners();
    active = null;
    startedAt = null;
    notifyListeners();
  }

  Future<String> reportUrl() async {
    if (active == null) throw StateError('No active emergency');
    return _service.reportPdfUrl(active!.id);
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }
}
