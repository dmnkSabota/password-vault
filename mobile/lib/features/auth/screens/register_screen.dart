import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_providers.dart';
import '../../../core/theme/app_theme.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(authNotifierProvider.notifier).register(
          _usernameCtrl.text.trim(),
          _emailCtrl.text.trim(),
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
                  // ── Header ─────────────────────────────────────────────
                  _RegisterBanner(),
                  const SizedBox(height: 40),

                  // ── Error ──────────────────────────────────────────────
                  if (authState.error != null) ...[
                    _ErrorBanner(message: authState.error!),
                    const SizedBox(height: 20),
                  ],

                  // ── Username ───────────────────────────────────────────
                  _TerminalLabel('// CHOOSE IDENTIFIER'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _usernameCtrl,
                    style: GoogleFonts.shareTechMono(color: context.cText, fontSize: 15),
                    decoration: const InputDecoration(
                      hintText: 'username',
                      prefixIcon: Icon(Icons.person_outline, size: 18),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? '> field required' : null,
                  ),
                  const SizedBox(height: 20),

                  // ── Email ──────────────────────────────────────────────
                  _TerminalLabel('// EMAIL ADDRESS'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.shareTechMono(color: context.cText, fontSize: 15),
                    decoration: const InputDecoration(
                      hintText: 'user@domain.com',
                      prefixIcon: Icon(Icons.alternate_email, size: 18),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return '> field required';
                      if (!v.contains('@')) return '> invalid email format';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // ── Password ───────────────────────────────────────────
                  _TerminalLabel('// SET PASSPHRASE'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    autocorrect: false,
                    enableSuggestions: false,
                    style: GoogleFonts.shareTechMono(color: context.cText, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'min. 8 characters',
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
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.isEmpty) return '> field required';
                      if (v.length < 8) return '> minimum 8 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // ── Confirm ────────────────────────────────────────────
                  _TerminalLabel('// CONFIRM PASSPHRASE'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _confirmCtrl,
                    obscureText: _obscureConfirm,
                    autocorrect: false,
                    enableSuggestions: false,
                    style: GoogleFonts.shareTechMono(color: context.cText, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'repeat passphrase',
                      prefixIcon: const Icon(Icons.lock_outline, size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 18,
                        ),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    validator: (v) {
                      if (v == null || v.isEmpty) return '> field required';
                      if (v != _passwordCtrl.text) return '> passphrases do not match';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // ── Submit ─────────────────────────────────────────────
                  FilledButton(
                    onPressed: authState.isLoading ? null : _submit,
                    child: authState.isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.black),
                          )
                        : const Text('[ CREATE USER ]'),
                  ),
                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('> ALREADY REGISTERED? SIGN IN'),
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

// ─── Local widgets ────────────────────────────────────────────────────────────

class _RegisterBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: context.cCard,
        border: Border.all(color: kPrimary.withValues(alpha: 0.4), width: 1),
      ),
      child: Column(
        children: [
          Text(
            '// CREATE NEW USER',
            style: GoogleFonts.shareTechMono(
              color: kPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'INITIALIZING SECURE ACCOUNT',
            style: GoogleFonts.shareTechMono(
              color: context.cTextSub,
              fontSize: 11,
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
