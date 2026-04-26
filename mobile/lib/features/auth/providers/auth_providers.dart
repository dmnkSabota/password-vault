import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/auth_notifier.dart';

export '../notifiers/auth_notifier.dart'
    show
        secureStorageProvider,
        biometricServiceProvider,
        apiClientProvider,
        authRepositoryProvider;

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isAuthenticated;
});

final isLockedProvider = Provider<bool>((ref) {
  final s = ref.watch(authNotifierProvider);
  return s.isAuthenticated && s.isLocked;
});

/// Makes GoRouter reactive to Riverpod auth state changes.
class AuthRouterNotifier extends ChangeNotifier {
  AuthRouterNotifier(Ref ref) {
    ref.listen<AuthState>(authNotifierProvider, (_, __) => notifyListeners());
  }
}
