import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/lock_screen.dart';
import '../../features/vault/screens/vault_screen.dart';
import '../../features/vault/screens/credential_detail_screen.dart';
import '../../features/vault/screens/credential_form_screen.dart';
import '../../features/generator/screens/generator_screen.dart';
import '../../features/settings/screens/settings_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = AuthRouterNotifier(ref);

  return GoRouter(
    initialLocation: '/vault',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final loggedIn = authState.isAuthenticated;
      final isLocked = authState.isLocked;
      final onAuthRoute =
          state.matchedLocation == '/login' || state.matchedLocation == '/register';
      final onLockRoute = state.matchedLocation == '/lock';

      if (!loggedIn && !onAuthRoute) return '/login';
      if (loggedIn && isLocked && !onLockRoute) return '/lock';
      if (loggedIn && !isLocked && onLockRoute) return '/vault';
      if (loggedIn && !isLocked && onAuthRoute) return '/vault';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/lock',
        builder: (context, state) => const LockScreen(),
      ),
      GoRoute(
        path: '/vault',
        builder: (context, state) => const VaultScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => const CredentialFormScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return CredentialDetailScreen(credentialId: id);
            },
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return CredentialFormScreen(credentialId: id);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/generator',
        builder: (context, state) => const GeneratorScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
