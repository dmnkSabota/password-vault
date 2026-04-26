import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/notifiers/auth_notifier.dart';
import '../data/vault_repository.dart';

final vaultRepositoryProvider = Provider<VaultRepository>((ref) {
  return VaultRepository(ref.watch(apiClientProvider));
});

class VaultState {
  final List<Credential> credentials;
  final bool isLoading;
  final String? error;

  const VaultState({
    this.credentials = const [],
    this.isLoading = false,
    this.error,
  });

  VaultState copyWith({
    List<Credential>? credentials,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return VaultState(
      credentials: credentials ?? this.credentials,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class VaultNotifier extends Notifier<VaultState> {
  late VaultRepository _repository;

  @override
  VaultState build() {
    _repository = ref.watch(vaultRepositoryProvider);
    return const VaultState();
  }

  Future<void> loadCredentials({String? category, String? q}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final credentials = await _repository.getCredentials(
        category: category,
        q: q,
      );
      state = state.copyWith(credentials: credentials, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createCredential(Map<String, dynamic> data) async {
    try {
      final credential = await _repository.createCredential(data);
      state = state.copyWith(
        credentials: [...state.credentials, credential],
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updateCredential(int id, Map<String, dynamic> data) async {
    try {
      final updated = await _repository.updateCredential(id, data);
      state = state.copyWith(
        credentials: state.credentials
            .map((c) => c.id == id ? updated : c)
            .toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteCredential(int id) async {
    try {
      await _repository.deleteCredential(id);
      state = state.copyWith(
        credentials: state.credentials.where((c) => c.id != id).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}
