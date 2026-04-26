import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../notifiers/generator_notifier.dart';
import '../providers/generator_providers.dart';
import '../../../core/theme/app_theme.dart';

class GeneratorScreen extends ConsumerStatefulWidget {
  const GeneratorScreen({super.key});

  @override
  ConsumerState<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends ConsumerState<GeneratorScreen> {
  Timer? _clipboardTimer;

  @override
  void dispose() {
    _clipboardTimer?.cancel();
    super.dispose();
  }

  Future<void> _copyPassword(String password) async {
    final delay =
        int.tryParse(dotenv.env['CLIPBOARD_CLEAR_DELAY'] ?? '30') ?? 30;
    await Clipboard.setData(ClipboardData(text: password));
    _clipboardTimer?.cancel();
    _clipboardTimer = Timer(Duration(seconds: delay), () {
      Clipboard.setData(const ClipboardData(text: ''));
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PASSWORD COPIED — CLEARS IN ${delay}s'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Color _strengthColor(PasswordStrength s) {
    switch (s) {
      case PasswordStrength.veryWeak:   return kError;
      case PasswordStrength.weak:       return Colors.orange;
      case PasswordStrength.fair:       return kPrimary;
      case PasswordStrength.strong:     return kAccent;
      case PasswordStrength.veryStrong: return kAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gen = ref.watch(generatorNotifierProvider);
    final notifier = ref.read(generatorNotifierProvider.notifier);
    final sc = _strengthColor(gen.strength);

    return Scaffold(
      appBar: AppBar(
        title: const Text('// PASSWORD GENERATOR'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.go('/vault'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Generated password display ────────────────────────────
          _SectionLabel('// GENERATED OUTPUT'),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.cCard,
              border: Border.all(color: kPrimary.withValues(alpha: 0.4), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  gen.password.isEmpty ? '—' : gen.password,
                  style: GoogleFonts.shareTechMono(
                    color: kPrimary,
                    fontSize: 18,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),

                // Strength bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('STRENGTH',
                        style: GoogleFonts.shareTechMono(
                            color: context.cTextSub, fontSize: 10, letterSpacing: 2)),
                    Text(
                      gen.strength.label.toUpperCase(),
                      style: GoogleFonts.shareTechMono(
                        color: sc,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: gen.strength.fraction,
                  minHeight: 4,
                  backgroundColor: context.cTextDim,
                  valueColor: AlwaysStoppedAnimation<Color>(sc),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Length ───────────────────────────────────────────────
          _SectionLabel('// LENGTH'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: context.cCard,
              border: Border.all(color: kPrimary.withValues(alpha: 0.25), width: 1),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('CHARACTERS',
                        style: GoogleFonts.shareTechMono(
                            color: context.cTextSub, fontSize: 12, letterSpacing: 1)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: kPrimary, width: 1),
                      ),
                      child: Text(
                        '${gen.length}',
                        style: GoogleFonts.shareTechMono(
                          color: kPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: Theme.of(context).sliderTheme,
                  child: Slider(
                    value: gen.length.toDouble(),
                    min: 6,
                    max: 64,
                    divisions: 58,
                    onChanged: (v) => notifier.setLength(v.round()),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('6', style: GoogleFonts.shareTechMono(color: context.cTextSub, fontSize: 10)),
                    Text('64', style: GoogleFonts.shareTechMono(color: context.cTextSub, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Character sets ───────────────────────────────────────
          _SectionLabel('// CHARACTER SETS'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: context.cCard,
              border: Border.all(color: kPrimary.withValues(alpha: 0.25), width: 1),
            ),
            child: Column(
              children: [
                _CyberSwitch(
                  label: 'UPPERCASE',
                  sublabel: 'A B C … Z',
                  value: gen.useUppercase,
                  onChanged: notifier.toggleUppercase,
                ),
                Divider(height: 1, color: kPrimary.withValues(alpha: 0.1)),
                _CyberSwitch(
                  label: 'LOWERCASE',
                  sublabel: 'a b c … z',
                  value: gen.useLowercase,
                  onChanged: notifier.toggleLowercase,
                ),
                Divider(height: 1, color: kPrimary.withValues(alpha: 0.1)),
                _CyberSwitch(
                  label: 'NUMBERS',
                  sublabel: '0 1 2 … 9',
                  value: gen.useNumbers,
                  onChanged: notifier.toggleNumbers,
                ),
                Divider(height: 1, color: kPrimary.withValues(alpha: 0.1)),
                _CyberSwitch(
                  label: 'SYMBOLS',
                  sublabel: '! @ # \$ % ^ & *',
                  value: gen.useSymbols,
                  onChanged: notifier.toggleSymbols,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ── Actions ──────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: notifier.generate,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('[ GENERATE ]'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: gen.password.isEmpty
                      ? null
                      : () => _copyPassword(gen.password),
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('[ COPY ]'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.shareTechMono(
          color: kPrimary, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w700),
    );
  }
}

class _CyberSwitch extends StatelessWidget {
  final String label;
  final String sublabel;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CyberSwitch({
    required this.label,
    required this.sublabel,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.shareTechMono(
                        color: value ? context.cText : context.cTextSub,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1)),
                Text(sublabel,
                    style: GoogleFonts.shareTechMono(
                        color: context.cTextSub, fontSize: 11)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
