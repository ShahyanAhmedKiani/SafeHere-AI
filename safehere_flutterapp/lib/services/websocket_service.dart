import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../core/constants.dart';

/// Live feed for the Monitor dashboard — receives a message whenever any
/// EmergencyEvent is created or updated on the backend (see /ws/monitor).
class MonitorSocketService {
  WebSocketChannel? _channel;
  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get stream => _controller.stream;

  void connect() {
    _channel = WebSocketChannel.connect(Uri.parse(ApiConfig.wsMonitorUrl));
    _channel!.stream.listen(
      (raw) => _controller.add(jsonDecode(raw as String) as Map<String, dynamic>),
      onError: (_) {},
      onDone: () {},
    );
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}
