import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/vault_repository.dart';
import '../notifiers/vault_notifier.dart';
import '../providers/vault_providers.dart';
import '../widgets/credential_tile.dart';
import '../../../core/theme/app_theme.dart';

class VaultScreen extends ConsumerStatefulWidget {
  const VaultScreen({super.key});

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen> {
  final _searchCtrl = TextEditingController();
  int? _selectedCategoryId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(vaultNotifierProvider.notifier).loadCredentials();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _search(String query) {
    setState(() => _searchQuery = query);
    ref.read(vaultNotifierProvider.notifier).loadCredentials(
          category: _selectedCategoryId?.toString(),
          q: query.isNotEmpty ? query : null,
        );
  }

  void _selectCategory(int? categoryId) {
    setState(() => _selectedCategoryId = categoryId);
    ref.read(vaultNotifierProvider.notifier).loadCredentials(
          category: categoryId?.toString(),
          q: _searchQuery.isNotEmpty ? _searchQuery : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    final vaultState = ref.watch(vaultNotifierProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('// VAULT'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 20),
            tooltip: 'Settings',
            onPressed: () => context.go('/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.auto_fix_high_outlined, size: 20),
            tooltip: 'Generator',
            onPressed: () => context.go('/generator'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // ── Search bar ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              style: GoogleFonts.shareTechMono(color: context.cText, fontSize: 14),
              decoration: InputDecoration(
                hintText: '>_ search credentials...',
                prefixIcon: const Icon(Icons.search, size: 18),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          _searchCtrl.clear();
                          _search('');
                        },
                      )
                    : null,
              ),
              onChanged: _search,
            ),
          ),

          // ── Category chips ───────────────────────────────────────────
          categoriesAsync.when(
            data: (categories) {
              if (categories.isEmpty) return const SizedBox(height: 8);
              return SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  children: [
                    _CyberChip(
                      label: 'ALL',
                      selected: _selectedCategoryId == null,
                      onTap: () => _selectCategory(null),
                    ),
                    ...categories.map((cat) => _CyberChip(
                          label: cat.name.toUpperCase(),
                          selected: _selectedCategoryId == cat.id,
                          onTap: () => _selectCategory(cat.id),
                        )),
                  ],
                ),
              );
            },
            loading: () => const SizedBox(height: 8),
            error: (_, __) => const SizedBox(height: 8),
          ),

          // ── Divider ──────────────────────────────────────────────────
          Divider(
              height: 1,
              thickness: 1,
              color: kPrimary.withValues(alpha: 0.15)),

          // ── List ─────────────────────────────────────────────────────
          Expanded(child: _buildBody(vaultState, categoriesAsync)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/vault/new'),
        icon: const Icon(Icons.add, size: 18),
        label: Text(
          'ADD RECORD',
          style: GoogleFonts.shareTechMono(
              fontWeight: FontWeight.w700, letterSpacing: 1.5, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildBody(
      VaultState state, AsyncValue<List<Category>> categoriesAsync) {
    if (state.isLoading && state.credentials.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'LOADING ENCRYPTED RECORDS...',
              style: GoogleFonts.shareTechMono(
                  color: context.cTextSub, fontSize: 11, letterSpacing: 2),
            ),
          ],
        ),
      );
    }

    if (state.error != null && state.credentials.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 40, color: kError),
              const SizedBox(height: 12),
              Text(
                state.error!,
                style: GoogleFonts.shareTechMono(color: kError, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () =>
                    ref.read(vaultNotifierProvider.notifier).loadCredentials(),
                child: const Text('[ RETRY ]'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.credentials.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_open_outlined,
                size: 56, color: kPrimary.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              'VAULT IS EMPTY',
              style: GoogleFonts.shareTechMono(
                  color: kPrimary, fontSize: 16, letterSpacing: 3),
            ),
            const SizedBox(height: 8),
            Text(
              '> tap ADD RECORD to store your first credential',
              style: GoogleFonts.shareTechMono(
                  color: context.cTextSub, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: kPrimary,
      backgroundColor: context.cCard,
      onRefresh: () => ref.read(vaultNotifierProvider.notifier).loadCredentials(
            category: _selectedCategoryId?.toString(),
            q: _searchQuery.isNotEmpty ? _searchQuery : null,
          ),
      child: Consumer(
        builder: (context, ref, _) {
          final cats = categoriesAsync.value;
          final categoryMap = cats != null
              ? {for (final c in cats) c.id: c.name}
              : <int, String>{};

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 100),
            itemCount: state.credentials.length,
            itemBuilder: (context, index) {
              final cred = state.credentials[index];
              return CredentialTile(
                credential: cred,
                categoryName: cred.categoryId != null
                    ? categoryMap[cred.categoryId]
                    : null,
                onTap: () => context.go('/vault/${cred.id}'),
                onDelete: () => ref
                    .read(vaultNotifierProvider.notifier)
                    .deleteCredential(cred.id),
              );
            },
          );
        },
      ),
    );
  }
}

// ─── Cyberpunk filter chip ────────────────────────────────────────────────────

class _CyberChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CyberChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: selected ? kPrimary : context.cCard,
            border: Border.all(
              color: selected ? kPrimary : kPrimary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.shareTechMono(
              color: selected ? Colors.black : context.cTextSub,
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}
