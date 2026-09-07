import 'api_client.dart';
import '../models/incident.dart';

class IncidentService {
  final _dio = ApiClient.instance.dio;

  Future<SafetyStatus> safetyStatus(double lat, double lng) async {
    final res = await _dio.get('/api/incidents/safety-status', queryParameters: {'lat': lat, 'lng': lng});
    return SafetyStatus.fromJson(res.data);
  }

  Future<List<Incident>> nearby(double lat, double lng) async {
    final res = await _dio.get('/api/incidents/nearby', queryParameters: {'lat': lat, 'lng': lng});
    return (res.data as List).map((e) => Incident.fromJson(e)).toList();
  }

  Future<Incident> report({
    required double lat,
    required double lng,
    required String type,
    required String severity,
    String? description,
  }) async {
    final res = await _dio.post('/api/incidents', data: {
      'latitude': lat,
      'longitude': lng,
      'type': type,
      'severity': severity,
      'description': description,
    });
    return Incident.fromJson(res.data);
  }
}
