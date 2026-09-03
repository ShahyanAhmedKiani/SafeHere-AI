import 'dart:io';

import 'package:dio/dio.dart';

import 'api_client.dart';
import '../models/emergency_event.dart';

class EmergencyService {
  final _dio = ApiClient.instance.dio;

  Future<List<EmergencyEvent>> list() async {
    final res = await _dio.get('/api/emergencies');
    return (res.data as List).map((e) => EmergencyEvent.fromJson(e)).toList();
  }

  Future<EmergencyEvent> get(String id) async {
    final res = await _dio.get('/api/emergencies/$id');
    return EmergencyEvent.fromJson(res.data);
  }

  Future<EmergencyEvent> activate({
    String type = 'sos',
    double? latitude,
    double? longitude,
    String? locationLabel,
    int? batteryLevel,
  }) async {
    final res = await _dio.post('/api/emergencies/activate', data: {
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'location_label': locationLabel,
      'battery_level': batteryLevel,
    });
    return EmergencyEvent.fromJson(res.data);
  }

  Future<EmergencyEvent> updateLocation(String id, double lat, double lng, {int? battery}) async {
    final res = await _dio.post('/api/emergencies/$id/location', data: {
      'latitude': lat,
      'longitude': lng,
      'battery_level': battery,
    });
    return EmergencyEvent.fromJson(res.data);
  }

  /// Uploads a raw evidence file (photo/video/audio) as multipart/form-data —
  /// the file bytes are streamed directly, never Base64-encoded.
  Future<EmergencyEvent> uploadEvidence(String id, String kind, File file) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: file.uri.pathSegments.last),
    });
    final res = await _dio.post('/api/emergencies/$id/evidence/$kind', data: formData);
    return EmergencyEvent.fromJson(res.data);
  }

  Future<EmergencyEvent> setStatus(String id, String status) async {
    final res = await _dio.post('/api/emergencies/$id/status', data: {'status': status});
    return EmergencyEvent.fromJson(res.data);
  }

  Future<String> reportPdfUrl(String id) async {
    return '${_dio.options.baseUrl}/api/emergencies/$id/report';
  }
}
