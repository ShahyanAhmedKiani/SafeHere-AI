import 'api_client.dart';
import '../models/journey.dart';

class JourneyService {
  final _dio = ApiClient.instance.dio;

  Future<List<Journey>> list() async {
    final res = await _dio.get('/api/journeys');
    return (res.data as List).map((e) => Journey.fromJson(e)).toList();
  }

  Future<Journey> create({
    required String fromLabel,
    required String toLabel,
    double? fromLat,
    double? fromLng,
    double? toLat,
    double? toLng,
    DateTime? expectedArrival,
    List<String> trustedContactIds = const [],
    bool notifyOnDeviation = true,
  }) async {
    final res = await _dio.post('/api/journeys', data: {
      'from_label': fromLabel,
      'to_label': toLabel,
      'from_lat': fromLat,
      'from_lng': fromLng,
      'to_lat': toLat,
      'to_lng': toLng,
      'expected_arrival': expectedArrival?.toIso8601String(),
      'trusted_contact_ids': trustedContactIds,
      'notify_on_deviation': notifyOnDeviation,
    });
    return Journey.fromJson(res.data);
  }

  Future<Journey> start(String id) async {
    final res = await _dio.post('/api/journeys/$id/start');
    return Journey.fromJson(res.data);
  }

  Future<Journey> updateLocation(String id, double lat, double lng) async {
    final res = await _dio.post('/api/journeys/$id/location', data: {
      'latitude': lat,
      'longitude': lng,
    });
    return Journey.fromJson(res.data);
  }

  Future<Journey> end(String id) async {
    final res = await _dio.post('/api/journeys/$id/end');
    return Journey.fromJson(res.data);
  }
}
