import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_providers.dart';
import '../../vault/data/vault_repository.dart';
import '../../vault/providers/vault_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    ref
        .read(authNotifierProvider.notifier)
        .isBiometricAvailable()
        .then((v) {
      if (mounted) setState(() => _biometricAvailable = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final biometricEnabled =
        ref.watch(authNotifierProvider).biometricEnabled;
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('// SETTINGS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.go('/vault'),
        ),
      ),
      body: ListView(
        children: [
          // ── Appearance ───────────────────────────────────────────
          _SectionHeader('// APPEARANCE'),
          _CyberTile(
            icon: _themeModeIcon(themeMode),
            title: 'THEME',
            subtitle: _themeModeLabel(themeMode).toUpperCase(),
            onTap: () {
              ref.read(themeModeProvider.notifier).set(
                    _nextThemeMode(themeMode),
                  );
            },
            trailing: const Icon(Icons.chevron_right, color: kPrimary, size: 18),
          ),

          _Divider(),

          // ── Categories ───────────────────────────────────────────
          _SectionHeader('// CATEGORIES'),
          categoriesAsync.when(
            data: (categories) => Column(
              children: [
                ...categories.map((cat) => _CategoryTile(
                      category: cat,
                      onRename: () =>
                          _showRenameCategoryDialog(context, ref, cat),
                      onDelete: () =>
                          _confirmDeleteCategory(context, ref, cat),
                    )),
                _CyberTile(
                  icon: Icons.add_circle_outline,
                  title: 'ADD CATEGORY',
                  subtitle: 'Create a new credential group',
                  onTap: () => _showAddCategoryDialog(context, ref),
                  trailing:
                      const Icon(Icons.chevron_right, color: kPrimary, size: 18),
                ),
              ],
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => _CyberTile(
              icon: Icons.add_circle_outline,
              title: 'ADD CATEGORY',
              subtitle: 'Create a new credential group',
              onTap: () => _showAddCategoryDialog(context, ref),
              trailing:
                  const Icon(Icons.chevron_right, color: kPrimary, size: 18),
            ),
          ),

          _Divider(),

          // ── Security ─────────────────────────────────────────────
          _SectionHeader('// SECURITY'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: context.cCard,
                border: Border.all(color: kPrimary.withValues(alpha: 0.25), width: 1),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.fingerprint, color: kPrimary, size: 20),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BIOMETRIC UNLOCK',
                            style: GoogleFonts.shareTechMono(
                              color: context.cText,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _biometricAvailable
                                ? 'Fingerprint / face unlock'
                                : 'No biometrics enrolled on device',
                            style: GoogleFonts.shareTechMono(
                                color: context.cTextSub, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: biometricEnabled,
                      onChanged: _biometricAvailable
                          ? (v) => ref
                              .read(authNotifierProvider.notifier)
                              .setBiometricEnabled(enabled: v)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),

          _Divider(),

          // ── Account ──────────────────────────────────────────────
          _SectionHeader('// ACCOUNT'),
          _CyberTile(
            icon: Icons.lock_reset_outlined,
            title: 'CHANGE PASSWORD',
            subtitle: 'Update your account passphrase',
            onTap: () => _showChangePasswordDialog(context, ref),
            trailing: const Icon(Icons.chevron_right, color: kPrimary, size: 18),
          ),
          const SizedBox(height: 4),
          _CyberTile(
            icon: Icons.logout,
            title: 'LOGOUT',
            subtitle: 'Sign out of this device',
            onTap: () => _confirmLogout(context, ref),
            trailing: const Icon(Icons.chevron_right, color: kPrimary, size: 18),
          ),
          const SizedBox(height: 4),
          _CyberTile(
            icon: Icons.delete_forever_outlined,
            title: 'DELETE ACCOUNT',
            subtitle: 'Permanently remove all data',
            titleColor: kError,
            iconColor: kError,
            onTap: () => _confirmDeleteAccount(context, ref),
            trailing: const Icon(Icons.chevron_right, color: kError, size: 18),
          ),

          const SizedBox(height: 40),

          // ── Footer ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '// AES-256-GCM ENCRYPTED  •  JWT AUTH  •  v1.0',
              style: GoogleFonts.shareTechMono(
                  color: context.cTextDim, fontSize: 10, letterSpacing: 1),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ─── Theme helpers ─────────────────────────────────────────────────────────

  ThemeMode _nextThemeMode(ThemeMode current) {
    switch (current) {
      case ThemeMode.system: return ThemeMode.dark;
      case ThemeMode.dark:   return ThemeMode.light;
      case ThemeMode.light:  return ThemeMode.system;
    }
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system: return 'System default';
      case ThemeMode.dark:   return 'Dark';
      case ThemeMode.light:  return 'Light';
    }
  }

  IconData _themeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system: return Icons.brightness_auto_outlined;
      case ThemeMode.dark:   return Icons.dark_mode_outlined;
      case ThemeMode.light:  return Icons.light_mode_outlined;
    }
  }

  // ─── Dialogs ───────────────────────────────────────────────────────────────

  Future<void> _showChangePasswordDialog(
      BuildContext context, WidgetRef ref) async {
    final formKey = GlobalKey<FormState>();
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('CHANGE PASSWORD'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: oldCtrl,
                obscureText: true,
                style: GoogleFonts.shareTechMono(color: context.cText, fontSize: 13),
                decoration: const InputDecoration(labelText: 'Current Password'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? '> required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: newCtrl,
                obscureText: true,
                style: GoogleFonts.shareTechMono(color: context.cText, fontSize: 13),
                decoration: const InputDecoration(labelText: 'New Password'),
                validator: (v) {
                  if (v == null || v.isEmpty) return '> required';
                  if (v.length < 8) return '> min 8 characters';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmCtrl,
                obscureText: true,
                style: GoogleFonts.shareTechMono(color: context.cText, fontSize: 13),
                decoration: const InputDecoration(labelText: 'Confirm New Password'),
                validator: (v) {
                  if (v == null || v.isEmpty) return '> required';
                  if (v != newCtrl.text) return '> passwords do not match';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('CONFIRM'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(authNotifierProvider.notifier)
          .changePassword(oldCtrl.text, newCtrl.text);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'PASSWORD UPDATED SUCCESSFULLY' : 'ERROR: CHANGE FAILED',
            ),
          ),
        );
      }
    }

    oldCtrl.dispose();
    newCtrl.dispose();
    confirmCtrl.dispose();
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('LOGOUT'),
        content: Text('Sign out from this device?',
            style: GoogleFonts.shareTechMono(color: context.cText, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('LOGOUT'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authNotifierProvider.notifier).logout();
    }
  }

  Future<void> _showAddCategoryDialog(
      BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('NEW CATEGORY'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: ctrl,
            autofocus: true,
            style: GoogleFonts.shareTechMono(color: context.cText, fontSize: 13),
            decoration: const InputDecoration(labelText: 'Category name'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? '> required' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
            },
            child: const Text('CREATE'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      try {
        await ref
            .read(vaultRepositoryProvider)
            .createCategory(ctrl.text.trim());
        ref.invalidate(categoriesProvider);
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ERROR: COULD NOT CREATE CATEGORY')),
          );
        }
      }
    }
    ctrl.dispose();
  }

  Future<void> _showRenameCategoryDialog(
      BuildContext context, WidgetRef ref, Category cat) async {
    final ctrl = TextEditingController(text: cat.name);
    final formKey = GlobalKey<FormState>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('RENAME CATEGORY'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: ctrl,
            autofocus: true,
            style: GoogleFonts.shareTechMono(color: context.cText, fontSize: 13),
            decoration: const InputDecoration(labelText: 'Category name'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? '> required' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      try {
        await ref
            .read(vaultRepositoryProvider)
            .updateCategory(cat.id, ctrl.text.trim());
        ref.invalidate(categoriesProvider);
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ERROR: COULD NOT RENAME CATEGORY')),
          );
        }
      }
    }
    ctrl.dispose();
  }

  Future<void> _confirmDeleteCategory(
      BuildContext context, WidgetRef ref, Category cat) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('DELETE CATEGORY'),
        content: Text(
          'Delete "${cat.name}"? Credentials in this category will become uncategorised.',
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
    if (confirmed == true && context.mounted) {
      try {
        await ref.read(vaultRepositoryProvider).deleteCategory(cat.id);
        ref.invalidate(categoriesProvider);
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ERROR: COULD NOT DELETE CATEGORY')),
          );
        }
      }
    }
  }

  Future<void> _confirmDeleteAccount(
      BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('DELETE ACCOUNT',
            style: GoogleFonts.shareTechMono(
                color: kError, fontWeight: FontWeight.w700)),
        content: Text(
          'This will permanently delete your account and ALL stored credentials.\n\nThis cannot be undone.',
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
    if (confirmed == true && context.mounted) {
      final success =
          await ref.read(authNotifierProvider.notifier).deleteAccount();
      if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ERROR: COULD NOT DELETE ACCOUNT')),
        );
      }
    }
  }
}

// ─── UI helpers ───────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: GoogleFonts.shareTechMono(
          color: kPrimary,
          fontSize: 11,
          letterSpacing: 2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, color: kPrimary.withValues(alpha: 0.1));
  }
}

class _CategoryTile extends StatelessWidget {
  final Category category;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const _CategoryTile({
    required this.category,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: context.cCard,
          border: Border.all(color: kPrimary.withValues(alpha: 0.2), width: 1),
        ),
        child: Row(
          children: [
            const Icon(Icons.folder_outlined, color: kPrimary, size: 18),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                category.name,
                style: GoogleFonts.shareTechMono(
                  color: context.cText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: kPrimary, size: 18),
              onPressed: onRename,
              tooltip: 'Rename',
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: kError, size: 18),
              onPressed: onDelete,
              tooltip: 'Delete',
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ],
        ),
      ),
    );
  }
}

class _CyberTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? titleColor;
  final Color? iconColor;

  const _CyberTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
    this.titleColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: context.cCard,
            border: Border.all(color: kPrimary.withValues(alpha: 0.2), width: 1),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor ?? kPrimary, size: 18),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.shareTechMono(
                        color: titleColor ?? context.cText,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.shareTechMono(
                          color: context.cTextSub, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
