import 'api_client.dart';
import '../models/trusted_contact.dart';

class ContactService {
  final _dio = ApiClient.instance.dio;

  Future<List<TrustedContact>> list() async {
    final res = await _dio.get('/api/contacts');
    return (res.data as List).map((e) => TrustedContact.fromJson(e)).toList();
  }

  Future<TrustedContact> create({
    required String name,
    required String relationship,
    String? phone,
    String? email,
    bool isEmergencyContact = true,
  }) async {
    final res = await _dio.post('/api/contacts', data: {
      'name': name,
      'relationship': relationship,
      'phone': phone,
      'email': email,
      'is_emergency_contact': isEmergencyContact,
    });
    return TrustedContact.fromJson(res.data);
  }

  Future<TrustedContact> update(String id, Map<String, dynamic> patch) async {
    final res = await _dio.put('/api/contacts/$id', data: patch);
    return TrustedContact.fromJson(res.data);
  }

  Future<void> delete(String id) => _dio.delete('/api/contacts/$id');

  Future<void> invite(String id) => _dio.post('/api/contacts/$id/invite');
}
