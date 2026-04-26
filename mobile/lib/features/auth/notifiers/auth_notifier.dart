import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/biometrics/biometric_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/auth_interceptor.dart';
import '../data/auth_repository.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLocked;
  final bool biometricEnabled;
  final String? username;
  final String? email;
  final String? error;
  final bool isLoading;

  const AuthState({
    this.isAuthenticated = false,
    this.isLocked = false,
    this.biometricEnabled = false,
    this.username,
    this.email,
    this.error,
    this.isLoading = false,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLocked,
    bool? biometricEnabled,
    String? username,
    String? email,
    String? error,
    bool? isLoading,
    bool clearError = false,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLocked: isLocked ?? this.isLocked,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      username: username ?? this.username,
      email: email ?? this.email,
      error: clearError ? null : error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Dependency providers live here so AuthNotifier can ref.watch() them
// without a circular import between auth_notifier and auth_providers.
final secureStorageProvider = Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(),
);

final biometricServiceProvider = Provider<BiometricService>(
  (_) => BiometricService(),
);

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  final refreshDio = Dio(
    BaseOptions(
      baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000/api',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
  final interceptor = AuthInterceptor(storage: storage, dio: refreshDio);
  return ApiClient(authInterceptor: interceptor);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiClientProvider));
});

class AuthNotifier extends Notifier<AuthState> {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _usernameKey = 'username';
  static const _biometricEnabledKey = 'biometric_enabled';

  AuthRepository get _repository => ref.read(authRepositoryProvider);
  FlutterSecureStorage get _storage => ref.read(secureStorageProvider);
  BiometricService get _biometricService => ref.read(biometricServiceProvider);

  @override
  AuthState build() {
    Future.microtask(checkStoredTokens);
    return const AuthState();
  }

  Future<void> checkStoredTokens() async {
    final accessToken = await _storage.read(key: _accessTokenKey);
    final username = await _storage.read(key: _usernameKey);
    final bioEnabledStr = await _storage.read(key: _biometricEnabledKey);
    final biometricEnabled = bioEnabledStr == 'true';
    if (accessToken != null) {
      state = state.copyWith(
        isAuthenticated: true,
        isLocked: true,
        biometricEnabled: biometricEnabled,
        username: username,
      );
    }
  }

  void lock() {
    if (state.isAuthenticated) {
      state = state.copyWith(isLocked: true);
    }
  }

  Future<bool> biometricUnlock() async {
    final success = await _biometricService.authenticate();
    if (success) {
      state = state.copyWith(isLocked: false);
    }
    return success;
  }

  Future<bool> isBiometricAvailable() => _biometricService.isAvailable();

  Future<void> setBiometricEnabled({required bool enabled}) async {
    await _storage.write(
      key: _biometricEnabledKey,
      value: enabled ? 'true' : 'false',
    );
    state = state.copyWith(biometricEnabled: enabled);
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await _repository.login(username, password);
      await _storage.write(key: _accessTokenKey, value: data['access'] as String);
      await _storage.write(key: _refreshTokenKey, value: data['refresh'] as String);
      await _storage.write(key: _usernameKey, value: username);
      state = state.copyWith(
        isAuthenticated: true,
        isLocked: false,
        username: username,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _extractError(e));
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.register(username, email, password);
      return await login(username, password);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _extractError(e));
      return false;
    }
  }

  Future<void> logout() async {
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    if (refreshToken != null) {
      await _repository.logout(refreshToken);
    }
    await _clearTokens();
    state = const AuthState();
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      await _repository.changePassword(oldPassword, newPassword);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    try {
      await _repository.deleteAccount();
      await _clearTokens();
      state = const AuthState();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _usernameKey);
  }

  String _extractError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        final messages = <String>[];
        data.forEach((key, value) {
          if (value is List) {
            messages.add(value.join(', '));
          } else {
            messages.add(value.toString());
          }
        });
        if (messages.isNotEmpty) return messages.join('\n');
      }
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) return 'Invalid credentials.';
      if (statusCode == 429) return 'Too many attempts. Try again later.';
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return 'Cannot connect to server. Is the backend running?';
      }
    }
    if (e is Exception) {
      final msg = e.toString();
      if (msg.contains('SocketException') || msg.contains('Connection')) {
        return 'Cannot connect to server. Is the backend running?';
      }
      return msg.replaceFirst('Exception: ', '');
    }
    return e.toString();
  }
}
