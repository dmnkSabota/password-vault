import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_providers.dart';
import '../../../core/theme/app_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(authNotifierProvider.notifier).login(
          _usernameCtrl.text.trim(),
          _passwordCtrl.text,
        );
    if (success && mounted) context.go('/vault');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Logo / header ──────────────────────────────────────
                  _HackerBanner(),
                  const SizedBox(height: 40),

                  // ── Error banner ───────────────────────────────────────
                  if (authState.error != null) ...[
                    _ErrorBanner(message: authState.error!),
                    const SizedBox(height: 20),
                  ],

                  // ── Username ───────────────────────────────────────────
                  _TerminalLabel('// IDENTIFIER'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _usernameCtrl,
                    style: GoogleFonts.shareTechMono(color: context.cText, fontSize: 15),
                    decoration: const InputDecoration(
                      hintText: 'enter username',
                      prefixIcon: Icon(Icons.person_outline, size: 18),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? '> field required' : null,
                  ),
                  const SizedBox(height: 20),

                  // ── Password ───────────────────────────────────────────
                  _TerminalLabel('// PASSPHRASE'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    style: GoogleFonts.shareTechMono(color: context.cText, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outline, size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 18,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? '> field required' : null,
                  ),
                  const SizedBox(height: 32),

                  // ── Submit button ─────────────────────────────────────
                  FilledButton(
                    onPressed: authState.isLoading ? null : _submit,
                    child: authState.isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Text('[ AUTHENTICATE ]'),
                  ),
                  const SizedBox(height: 16),

                  // ── Register link ─────────────────────────────────────
                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: const Text('> NO ACCOUNT? REGISTER HERE'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _HackerBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: context.cCard,
        border: Border.all(color: kPrimary.withValues(alpha: 0.4), width: 1),
      ),
      child: Column(
        children: [
          Text(
            '██████████████████████',
            style: GoogleFonts.shareTechMono(
              color: kPrimary.withValues(alpha: 0.25),
              fontSize: 14,
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            '🔐 PASSWORD VAULT',
            style: GoogleFonts.shareTechMono(
              color: kPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'v1.0 // AES-256-GCM ENCRYPTED',
            style: GoogleFonts.shareTechMono(
              color: context.cTextSub,
              fontSize: 11,
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            '██████████████████████',
            style: GoogleFonts.shareTechMono(
              color: kPrimary.withValues(alpha: 0.25),
              fontSize: 14,
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TerminalLabel extends StatelessWidget {
  final String text;
  const _TerminalLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.shareTechMono(
        color: kPrimary,
        fontSize: 11,
        letterSpacing: 2,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kError.withValues(alpha: 0.1),
        border: Border.all(color: kError.withValues(alpha: 0.6), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_outlined, color: kError, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.shareTechMono(color: kError, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
