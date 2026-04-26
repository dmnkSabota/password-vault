import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/vault_repository.dart';
import '../notifiers/vault_notifier.dart';

export '../notifiers/vault_notifier.dart' show vaultRepositoryProvider;

final vaultNotifierProvider =
    NotifierProvider<VaultNotifier, VaultState>(VaultNotifier.new);

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repo = ref.watch(vaultRepositoryProvider);
  return repo.getCategories();
});
