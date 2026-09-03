/// Central place for environment-dependent values.
///
/// Override at build/run time with:
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
/// (10.0.2.2 is how the Android emulator reaches your host machine's localhost;
/// use your machine's LAN IP for a physical device, or http://localhost:8000 for iOS simulator.)
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://trend-float-anytime.ngrok-free.dev/',
  );

  static String get wsMonitorUrl =>
      '${baseUrl.replaceFirst('http', 'ws')}/ws/monitor';
}

class AppConstants {
  static const sosHoldDurationMs = 1600;
  static const gpsLogIntervalSeconds = 12;
  static const journeyLocationIntervalSeconds = 10;
  static const evidencePhotoIntervalSeconds = 20;
  static const evidenceVideoChunkSeconds = 30;
  static const evidenceAudioChunkSeconds = 60;

  static const emergencyNumbers = [
    {'name': 'Police', 'number': '15'},
    {'name': 'Rescue', 'number': '1122'},
    {'name': 'Edhi Ambulance', 'number': '115'},
    {'name': 'Fire Brigade', 'number': '16'},
    {'name': 'Women Helpline', 'number': '104'},
    {'name': 'Motorway Police', 'number': '130'},
  ];
}
