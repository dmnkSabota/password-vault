import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  await dotenv.load(fileName: '.env');
  runApp(const ProviderScope(child: PasswordVaultApp()));
}

class PasswordVaultApp extends ConsumerWidget {
  const PasswordVaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Password Vault',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => _AutoLockObserver(child: child!),
    );
  }
}

/// Observes the app lifecycle and locks the vault after the number of seconds
/// specified in the `AUTO_LOCK_TIMEOUT` environment variable (default: 120)
/// of background time.
class _AutoLockObserver extends ConsumerStatefulWidget {
  final Widget child;

  const _AutoLockObserver({required this.child});

  @override
  ConsumerState<_AutoLockObserver> createState() => _AutoLockObserverState();
}

class _AutoLockObserverState extends ConsumerState<_AutoLockObserver>
    with WidgetsBindingObserver {
  DateTime? _pausedAt;

  static int get _timeoutSeconds {
    final raw = dotenv.env['AUTO_LOCK_TIMEOUT'];
    return int.tryParse(raw ?? '') ?? 120;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _pausedAt = DateTime.now();
        break;
      case AppLifecycleState.resumed:
        final paused = _pausedAt;
        if (paused != null) {
          final elapsed = DateTime.now().difference(paused).inSeconds;
          if (elapsed >= _timeoutSeconds) {
            ref.read(authNotifierProvider.notifier).lock();
          }
          _pausedAt = null;
        }
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
