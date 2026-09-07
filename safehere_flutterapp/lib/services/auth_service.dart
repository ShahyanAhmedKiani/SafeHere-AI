import 'api_client.dart';
import 'secure_storage_service.dart';
import '../models/user.dart';

class AuthService {
  final _dio = ApiClient.instance.dio;

  Future<void> register({required String fullName, required String email, required String password}) async {
    final res = await _dio.post('/api/auth/register', data: {
      'full_name': fullName,
      'email': email,
      'password': password,
    });
    await SecureStorageService.saveTokens(
      access: res.data['access_token'],
      refresh: res.data['refresh_token'],
    );
  }

  Future<void> login({required String email, required String password}) async {
    final res = await _dio.post('/api/auth/login', data: {'email': email, 'password': password});
    await SecureStorageService.saveTokens(
      access: res.data['access_token'],
      refresh: res.data['refresh_token'],
    );
  }

  Future<AppUser> me() async {
    final res = await _dio.get('/api/auth/me');
    return AppUser.fromJson(res.data);
  }

  Future<void> requestOtp(String email, {String purpose = 'verify_email'}) async {
    await _dio.post('/api/auth/otp/request', data: {'email': email, 'purpose': purpose});
  }

  Future<void> verifyOtp(String email, String code, {String purpose = 'verify_email'}) async {
    await _dio.post('/api/auth/otp/verify', data: {'email': email, 'code': code, 'purpose': purpose});
  }

  Future<void> forgotPassword(String email) async {
    await _dio.post('/api/auth/forgot-password', data: {'email': email});
  }

  Future<void> resetPassword({required String email, required String code, required String newPassword}) async {
    await _dio.post('/api/auth/reset-password', data: {
      'email': email,
      'code': code,
      'new_password': newPassword,
    });
  }

  Future<void> logout() => SecureStorageService.clear();
}
