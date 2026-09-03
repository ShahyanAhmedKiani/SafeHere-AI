import 'api_client.dart';

class NearbyService {
  final String name;
  final String type;
  final double? latitude;
  final double? longitude;
  final int? distanceM;
  final String? direction;
  final String? phone;

  NearbyService({
    required this.name,
    required this.type,
    this.latitude,
    this.longitude,
    this.distanceM,
    this.direction,
    this.phone,
  });

  factory NearbyService.fromJson(Map<String, dynamic> json) => NearbyService(
        name: json['name'],
        type: json['type'],
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        distanceM: json['distance_m'],
        direction: json['direction'],
        phone: json['phone']?.toString(),
      );
}

class ServicesService {
  final _dio = ApiClient.instance.dio;

  Future<List<NearbyService>> nearby(double lat, double lng) async {
    final res = await _dio.get('/api/services/nearby', queryParameters: {'lat': lat, 'lng': lng});
    final services = (res.data['services'] as List).map((e) => NearbyService.fromJson(e)).toList();
    return services;
  }
}
