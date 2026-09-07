/// Central place for environment-dependent values.
///
/// Production default points at the deployed Azure backend. For local
/// development against a backend running on your own machine, override it:
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
/// (10.0.2.2 is how the Android emulator reaches your host machine's localhost;
/// use your machine's LAN IP for a physical device, or http://localhost:8000 for iOS simulator.)
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://safehar-ai-f2eddne4c6gtd4ga.southindia-01.azurewebsites.net/',
  );

  static String get wsMonitorUrl =>
      '${baseUrl.replaceFirst('http', 'ws')}/ws/monitor';
}

class AppConstants {
  static const sosHoldDurationMs = 1600;
  static const gpsLogIntervalSeconds = 12;
  static const journeyLocationIntervalSeconds = 10;

  /// SOS evidence: capture runs continuously, but photos/video/audio are
  /// batched and uploaded to the incident's Google Drive folder once per
  /// cycle. The first upload fires after this many seconds — not
  /// immediately — matching the spec's "first evidence update after 1
  /// minute" requirement.
  static const evidenceUploadCycleSeconds = 60;

  static const emergencyNumbers = [
    {'name': 'Police', 'number': '15'},
    {'name': 'Rescue', 'number': '1122'},
    {'name': 'Edhi Ambulance', 'number': '115'},
    {'name': 'Fire Brigade', 'number': '16'},
    {'name': 'Women Helpline', 'number': '104'},
    {'name': 'Motorway Police', 'number': '130'},
  ];
}
