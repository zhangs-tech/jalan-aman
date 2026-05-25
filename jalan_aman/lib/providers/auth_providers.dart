import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jalan_aman/services/api/auth_service.dart';
import 'package:jalan_aman/services/secure_storage.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  const AuthState({this.status = AuthStatus.unknown});
  AuthState copyWith({AuthStatus? status}) =>
      AuthState(status: status ?? this.status);
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authenticated = await AuthService.isAuthenticated();
    state = state.copyWith(
      status:
          authenticated ? AuthStatus.authenticated : AuthStatus.unauthenticated,
    );
  }

  Future<bool> login(String email, String password) async {
    final result = await AuthService.login(email: email, password: password);
    if (result['statusCode'] == 200) {
      state = state.copyWith(status: AuthStatus.authenticated);
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    return AuthService.register(
      name: name,
      phone: phone,
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await SecureStorage.delete('accessToken');
    await prefs.remove('userId');
    await prefs.remove('name');
    await prefs.remove('email');
    await prefs.remove('phone');
    await prefs.remove('role');
    state = state.copyWith(status: AuthStatus.unauthenticated);
  }
}

final authStateProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());
