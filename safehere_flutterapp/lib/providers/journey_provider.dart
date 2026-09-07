import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../models/journey.dart';
import '../services/journey_service.dart';
import '../services/location_service.dart';

class JourneyProvider extends ChangeNotifier {
  final _service = JourneyService();

  Journey? active;
  Timer? _locationTimer;
  StreamSubscription? _positionSub;

  Future<Journey> create({
    required String fromLabel,
    required String toLabel,
    double? toLat,
    double? toLng,
    List<String> trustedContactIds = const [],
    bool notifyOnDeviation = true,
  }) async {
    final position = await LocationService.currentPosition();
    return _service.create(
      fromLabel: fromLabel,
      toLabel: toLabel,
      fromLat: position?.latitude,
      fromLng: position?.longitude,
      toLat: toLat,
      toLng: toLng,
      trustedContactIds: trustedContactIds,
      notifyOnDeviation: notifyOnDeviation,
    );
  }

  Future<void> startTracking(Journey journey) async {
    active = await _service.start(journey.id);
    notifyListeners();

    _locationTimer = Timer.periodic(
      const Duration(seconds: AppConstants.journeyLocationIntervalSeconds),
      (_) => _pushLocation(),
    );
  }

  Future<void> _pushLocation() async {
    if (active == null) return;
    final position = await LocationService.currentPosition();
    if (position == null) return;
    try {
      active = await _service.updateLocation(active!.id, position.latitude, position.longitude);
      notifyListeners();
    } catch (_) {
      // network hiccup — the next periodic tick will retry.
    }
  }

  Future<void> endJourney() async {
    if (active == null) return;
    _locationTimer?.cancel();
    await _positionSub?.cancel();
    active = await _service.end(active!.id);
    notifyListeners();
    active = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _positionSub?.cancel();
    super.dispose();
  }
}
