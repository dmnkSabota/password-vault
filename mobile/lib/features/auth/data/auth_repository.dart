import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class AuthRepository {
  final ApiClient _client;

  const AuthRepository(this._client);

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/auth/login/',
      data: {'username': username, 'password': password},
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/auth/register/',
      data: {
        'username': username,
        'email': email,
        'password': password,
        'password2': password,
      },
    );
    return response.data!;
  }

  Future<void> logout(String refreshToken) async {
    try {
      await _client.post<void>(
        '/auth/logout/',
        data: {'refresh': refreshToken},
      );
    } on DioException catch (_) {
      // Ignore errors on logout — tokens will be cleared locally regardless.
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _client.post<void>(
      '/auth/change-password/',
      data: {'old_password': oldPassword, 'new_password': newPassword},
    );
  }

  Future<void> deleteAccount() async {
    await _client.delete<void>('/users/delete/');
  }
}
