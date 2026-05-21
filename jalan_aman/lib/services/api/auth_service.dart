import 'package:jalan_aman/services/api/api_client.dart';
import 'package:jalan_aman/services/secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    return ApiClient.post('/auth/register', {
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
    });
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final result = await ApiClient.post('/auth/login', {
      'email': email,
      'password': password,
    });

    if (result['statusCode'] == 200) {
      final data = result['data'];
      final accessToken = data['accessToken'] as String?;
      final user = data['user'] as Map<String, dynamic>?;
      final prefs = await SharedPreferences.getInstance();
      if (accessToken != null) {
        await SecureStorage.write('accessToken', accessToken);
      }
      if (user != null) {
        await prefs.setString('userId', user['id']?.toString() ?? '');
        await prefs.setString('email', user['email']?.toString() ?? '');
        await prefs.setString('name', user['name']?.toString() ?? '');
        await prefs.setString('phone', user['phone']?.toString() ?? '');
        await prefs.setString('role', user['role']?.toString() ?? '');
      }
    }

    return result;
  }

  static Future<bool> isAuthenticated() async {
    final token = await SecureStorage.read('accessToken');
    if (token == null || token.isEmpty) return false;

    final result = await ApiClient.get('/auth/me', auth: true);
    return result['statusCode'] == 200;
  }
}
