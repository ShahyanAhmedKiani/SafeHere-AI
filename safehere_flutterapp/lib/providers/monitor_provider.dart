import 'package:flutter/foundation.dart';

import '../models/emergency_event.dart';
import '../services/emergency_service.dart';
import '../services/websocket_service.dart';

class MonitorProvider extends ChangeNotifier {
  final _service = EmergencyService();
  final _socket = MonitorSocketService();

  List<EmergencyEvent> events = [];
  bool loading = false;

  Future<void> load() async {
    loading = true;
    notifyListeners();
    try {
      events = await _service.list();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void connectRealtime() {
    _socket.connect();
    _socket.stream.listen((message) {
      final data = message['emergency'] as Map<String, dynamic>?;
      if (data == null) return;
      final event = EmergencyEvent.fromJson(data);
      final idx = events.indexWhere((e) => e.id == event.id);
      if (idx >= 0) {
        events[idx] = event;
      } else {
        events = [event, ...events];
      }
      notifyListeners();
    });
  }

  Future<void> setStatus(String id, String status) async {
    await _service.setStatus(id, status);
    await load();
  }

  @override
  void dispose() {
    _socket.disconnect();
    super.dispose();
  }
}
