import 'api_client.dart';
import '../models/user.dart';

class UserService {
  final _dio = ApiClient.instance.dio;

  Future<AppUser> updateMe(Map<String, dynamic> patch) async {
    final res = await _dio.put('/api/users/me', data: patch);
    return AppUser.fromJson(res.data);
  }
}
