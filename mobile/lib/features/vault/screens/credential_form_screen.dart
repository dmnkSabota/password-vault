import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/vault_providers.dart';
import '../../../core/theme/app_theme.dart';

class CredentialFormScreen extends ConsumerStatefulWidget {
  final int? credentialId;
  const CredentialFormScreen({super.key, this.credentialId});

  @override
  ConsumerState<CredentialFormScreen> createState() =>
      _CredentialFormScreenState();
}

class _CredentialFormScreenState extends ConsumerState<CredentialFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isLoadingCredential = false;
  int? _selectedCategoryId;

  bool get _isEditing => widget.credentialId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) _loadExisting();
  }

  Future<void> _loadExisting() async {
    setState(() => _isLoadingCredential = true);
    try {
      final c = await ref
          .read(vaultRepositoryProvider)
          .getCredential(widget.credentialId!);
      if (mounted) {
        setState(() {
          _titleCtrl.text = c.title;
          _usernameCtrl.text = c.username;
          _passwordCtrl.text = c.password;
          _urlCtrl.text = c.url ?? '';
          _notesCtrl.text = c.notes ?? '';
          _selectedCategoryId = c.categoryId;
          _isLoadingCredential = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingCredential = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _urlCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final data = {
      'title': _titleCtrl.text.trim(),
      'username': _usernameCtrl.text.trim(),
      'password': _passwordCtrl.text,
      if (_urlCtrl.text.trim().isNotEmpty) 'url': _urlCtrl.text.trim(),
      if (_notesCtrl.text.trim().isNotEmpty) 'notes': _notesCtrl.text.trim(),
      if (_selectedCategoryId != null) 'category': _selectedCategoryId,
    };

    final notifier = ref.read(vaultNotifierProvider.notifier);
    final success = _isEditing
        ? await notifier.updateCredential(widget.credentialId!, data)
        : await notifier.createCredential(data);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        if (_isEditing) {
          context.pop();
        } else {
          context.go('/vault');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ERROR: FAILED TO SAVE RECORD')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingCredential) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? '// EDIT RECORD' : '// NEW RECORD'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('LOADING RECORD...',
                  style: GoogleFonts.shareTechMono(
                      color: context.cTextSub, fontSize: 11, letterSpacing: 2)),
            ],
          ),
        ),
      );
    }

    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '// EDIT RECORD' : '// NEW RECORD'),
        leading: IconButton(
          icon: const Icon(Icons.close, size: 20),
          onPressed: () =>
              _isEditing ? context.pop() : context.go('/vault'),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _FieldLabel('// TITLE *'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _titleCtrl,
              style: GoogleFonts.shareTechMono(color: context.cText, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'e.g. GitHub, Gmail, Bank',
                prefixIcon: Icon(Icons.label_outline, size: 18),
              ),
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? '> required' : null,
            ),
            const SizedBox(height: 20),

            _FieldLabel('// USERNAME'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _usernameCtrl,
              style: GoogleFonts.shareTechMono(color: context.cText, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'username or email',
                prefixIcon: Icon(Icons.person_outline, size: 18),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 20),

            _FieldLabel('// PASSWORD *'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscurePassword,
              style: GoogleFonts.shareTechMono(color: context.cText, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'enter password',
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
              validator: (v) =>
                  (v == null || v.isEmpty) ? '> required' : null,
            ),
            const SizedBox(height: 20),

            _FieldLabel('// URL (OPTIONAL)'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _urlCtrl,
              keyboardType: TextInputType.url,
              style: GoogleFonts.shareTechMono(color: context.cText, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'https://example.com',
                prefixIcon: Icon(Icons.link, size: 18),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 20),

            // ── Category dropdown ──────────────────────────────────────
            categoriesAsync.when(
              data: (categories) {
                if (categories.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel('// CATEGORY'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<int?>(
                      initialValue: _selectedCategoryId,
                      dropdownColor: context.cCard,
                      style: GoogleFonts.shareTechMono(
                          color: context.cText, fontSize: 14),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.folder_outlined, size: 18),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text('No Category',
                              style: GoogleFonts.shareTechMono(
                                  color: context.cTextSub, fontSize: 13)),
                        ),
                        ...categories.map((cat) => DropdownMenuItem(
                              value: cat.id,
                              child: Text(cat.name,
                                  style: GoogleFonts.shareTechMono(
                                      color: context.cText, fontSize: 13)),
                            )),
                      ],
                      onChanged: (val) =>
                          setState(() => _selectedCategoryId = val),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            _FieldLabel('// NOTES (OPTIONAL)'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 4,
              style: GoogleFonts.shareTechMono(color: context.cText, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'any additional notes...',
                prefixIcon: Icon(Icons.notes, size: 18),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),

            FilledButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black),
                    )
                  : Text(_isEditing ? '[ SAVE CHANGES ]' : '[ SAVE RECORD ]'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

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
