import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_providers.dart';
import '../../../core/theme/app_theme.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen>
    with SingleTickerProviderStateMixin {
  bool _isAuthenticating = false;
  String? _error;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(authNotifierProvider).biometricEnabled) {
        _authenticate();
      }
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    setState(() {
      _isAuthenticating = true;
      _error = null;
    });
    final success =
        await ref.read(authNotifierProvider.notifier).biometricUnlock();
    if (mounted) {
      setState(() => _isAuthenticating = false);
      if (!success) {
        setState(() => _error = 'AUTHENTICATION FAILED — TRY AGAIN');
      }
    }
  }

  Future<void> _logout() async =>
      ref.read(authNotifierProvider.notifier).logout();

  @override
  Widget build(BuildContext context) {
    final biometricEnabled =
        ref.watch(authNotifierProvider).biometricEnabled;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Pulsing lock icon ──────────────────────────────────
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, __) => Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: kPrimary.withValues(alpha: _pulseAnim.value),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.lock_outline,
                      size: 52,
                      color: kPrimary.withValues(alpha: _pulseAnim.value),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Title ──────────────────────────────────────────────
                Text(
                  'VAULT LOCKED',
                  style: GoogleFonts.shareTechMono(
                    color: kPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '// BIOMETRIC AUTHENTICATION REQUIRED',
                  style: GoogleFonts.shareTechMono(
                    color: context.cTextSub,
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // ── Error ──────────────────────────────────────────────
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: kError.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      _error!,
                      style: GoogleFonts.shareTechMono(
                          color: kError, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Biometric button ───────────────────────────────────
                if (biometricEnabled) ...[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isAuthenticating ? null : _authenticate,
                      icon: _isAuthenticating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Icon(Icons.fingerprint, size: 20),
                      label: Text(
                        _isAuthenticating
                            ? 'SCANNING...'
                            : '[ BIOMETRIC UNLOCK ]',
                      ),
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.cCard,
                      border:
                          Border.all(color: kPrimary.withValues(alpha: 0.2), width: 1),
                    ),
                    child: Text(
                      'Biometric unlock is disabled.\nEnable it in Settings → Security,\nor log in again to access the vault.',
                      style: GoogleFonts.shareTechMono(
                          color: context.cTextSub, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                // ── Logout ─────────────────────────────────────────────
                TextButton(
                  onPressed: _logout,
                  child: const Text('> LOGOUT / SWITCH USER'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
