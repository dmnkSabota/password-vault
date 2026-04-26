import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/vault_repository.dart';
import '../providers/vault_providers.dart';
import '../../../core/theme/app_theme.dart';

class CredentialDetailScreen extends ConsumerStatefulWidget {
  final int credentialId;

  const CredentialDetailScreen({super.key, required this.credentialId});

  @override
  ConsumerState<CredentialDetailScreen> createState() =>
      _CredentialDetailScreenState();
}

class _CredentialDetailScreenState
    extends ConsumerState<CredentialDetailScreen> {
  Credential? _credential;
  bool _isLoading = true;
  String? _error;
  bool _passwordVisible = false;
  Timer? _clipboardTimer;

  @override
  void initState() {
    super.initState();
    _loadCredential();
  }

  @override
  void dispose() {
    _clipboardTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCredential() async {
    try {
      final c = await ref
          .read(vaultRepositoryProvider)
          .getCredential(widget.credentialId);
      if (mounted) setState(() {
        _credential = c;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _copyToClipboard(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    _clipboardTimer?.cancel();
    _clipboardTimer = Timer(const Duration(seconds: 30), () {
      Clipboard.setData(const ClipboardData(text: ''));
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$label COPIED — CLEARS IN 30s'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('COULD NOT OPEN URL')),
        );
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('DELETE RECORD'),
        content: Text(
          'Permanently delete this credential?\nThis cannot be undone.',
          style: GoogleFonts.shareTechMono(color: context.cText, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: kError, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref
          .read(vaultNotifierProvider.notifier)
          .deleteCredential(widget.credentialId);
      if (mounted) context.go('/vault');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(vaultNotifierProvider, (previous, next) {
      if (previous != null && !next.isLoading && mounted) {
        _loadCredential();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(_credential?.title.toUpperCase() ?? '// RECORD'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.go('/vault'),
        ),
        actions: [
          if (_credential != null) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              tooltip: 'Edit',
              onPressed: () =>
                  context.push('/vault/${widget.credentialId}/edit'),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              tooltip: 'Delete',
              onPressed: _confirmDelete,
              color: kError,
            ),
            const SizedBox(width: 4),
          ],
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('DECRYPTING RECORD...',
                style: GoogleFonts.shareTechMono(
                    color: context.cTextSub, fontSize: 11, letterSpacing: 2)),
          ],
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Text('ERROR: $_error',
            style: GoogleFonts.shareTechMono(color: kError, fontSize: 13)),
      );
    }
    if (_credential == null) {
      return Center(
        child: Text('RECORD NOT FOUND',
            style: GoogleFonts.shareTechMono(
                color: context.cTextSub, fontSize: 13)),
      );
    }

    final c = _credential!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionLabel('// DATA RECORD'),
        const SizedBox(height: 12),

        _DataBlock(children: [
          _DataRow(label: 'TITLE', value: c.title, icon: Icons.label_outline),
          if (c.categoryId != null) ...[
            _Divider(),
            _DataRow(
                label: 'CATEGORY ID',
                value: c.categoryId.toString(),
                icon: Icons.folder_outlined),
          ],
        ]),
        const SizedBox(height: 12),

        _SectionLabel('// CREDENTIALS'),
        const SizedBox(height: 12),
        _DataBlock(children: [
          _DataRow(
            label: 'USERNAME',
            value: c.username,
            icon: Icons.person_outline,
            action: IconButton(
              icon: const Icon(Icons.copy_outlined, size: 16, color: kPrimary),
              tooltip: 'Copy',
              onPressed: () => _copyToClipboard(c.username, 'USERNAME'),
            ),
          ),
          _Divider(),
          _DataRow(
            label: 'PASSWORD',
            value: _passwordVisible ? c.password : '●' * 12,
            icon: Icons.lock_outline,
            mono: true,
            action: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    _passwordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 16,
                    color: kPrimary,
                  ),
                  onPressed: () =>
                      setState(() => _passwordVisible = !_passwordVisible),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_outlined, size: 16, color: kPrimary),
                  tooltip: 'Copy',
                  onPressed: () => _copyToClipboard(c.password, 'PASSWORD'),
                ),
              ],
            ),
          ),
        ]),

        if (c.url != null && c.url!.isNotEmpty) ...[
          const SizedBox(height: 12),
          _SectionLabel('// URL'),
          const SizedBox(height: 12),
          _DataBlock(children: [
            _DataRow(
              label: 'URL',
              value: c.url!,
              icon: Icons.link,
              action: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy_outlined,
                        size: 16, color: kPrimary),
                    onPressed: () => _copyToClipboard(c.url!, 'URL'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.open_in_new,
                        size: 16, color: kPrimary),
                    onPressed: () => _launchUrl(c.url!),
                  ),
                ],
              ),
            ),
          ]),
        ],

        if (c.notes != null && c.notes!.isNotEmpty) ...[
          const SizedBox(height: 12),
          _SectionLabel('// NOTES'),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.cCard,
              border:
                  Border.all(color: kPrimary.withValues(alpha: 0.25), width: 1),
            ),
            child: Text(
              c.notes!,
              style:
                  GoogleFonts.shareTechMono(color: context.cText, fontSize: 13),
            ),
          ),
        ],
        const SizedBox(height: 32),
      ],
    );
  }
}

// ─── Shared building blocks ───────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.shareTechMono(
          color: kPrimary,
          fontSize: 11,
          letterSpacing: 2,
          fontWeight: FontWeight.w700),
    );
  }
}

class _DataBlock extends StatelessWidget {
  final List<Widget> children;
  const _DataBlock({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cCard,
        border: Border.all(color: kPrimary.withValues(alpha: 0.25), width: 1),
      ),
      child: Column(children: children),
    );
  }
}

class _DataRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Widget? action;
  final bool mono;

  const _DataRow({
    required this.label,
    required this.value,
    required this.icon,
    this.action,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: kPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.shareTechMono(
                      color: context.cTextSub,
                      fontSize: 10,
                      letterSpacing: 1.5),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: GoogleFonts.shareTechMono(
                    color: context.cText,
                    fontSize: mono ? 14 : 13,
                    letterSpacing: mono ? 2 : 0,
                  ),
                ),
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
        height: 1,
        thickness: 1,
        color: kPrimary.withValues(alpha: 0.12));
  }
}
