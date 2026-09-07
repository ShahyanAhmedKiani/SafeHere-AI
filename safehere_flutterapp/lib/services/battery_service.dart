import 'package:battery_plus/battery_plus.dart';

class BatteryService {
  static final _battery = Battery();
  static Future<int> level() => _battery.batteryLevel;
}
