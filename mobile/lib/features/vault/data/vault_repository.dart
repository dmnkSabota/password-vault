import '../../../core/network/api_client.dart';

class Credential {
  final int id;
  final String title;
  final String username;
  final String password;
  final String? url;
  final String? notes;
  final int? categoryId;

  const Credential({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
    this.url,
    this.notes,
    this.categoryId,
  });

  factory Credential.fromJson(Map<String, dynamic> json) {
    return Credential(
      id: json['id'] as int,
      title: json['title'] as String,
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      url: json['url'] as String?,
      notes: json['notes'] as String?,
      categoryId: json['category'] as int?,
    );
  }
}

class Category {
  final int id;
  final String name;

  const Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

class VaultRepository {
  final ApiClient _client;

  const VaultRepository(this._client);

  Future<List<Credential>> getCredentials({
    String? category,
    String? q,
  }) async {
    final response = await _client.get<dynamic>(
      '/vault/credentials/',
      queryParameters: {
        if (category != null && category.isNotEmpty) 'category': category,
        if (q != null && q.isNotEmpty) 'q': q,
      },
    );
    return _extractList(response.data)
        .cast<Map<String, dynamic>>()
        .map(Credential.fromJson)
        .toList();
  }

  Future<Credential> getCredential(int id) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/vault/credentials/$id/',
    );
    return Credential.fromJson(response.data!);
  }

  Future<Credential> createCredential(Map<String, dynamic> data) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/vault/credentials/',
      data: _toRequestData(data),
    );
    return Credential.fromJson(response.data!);
  }

  Future<Credential> updateCredential(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client.put<Map<String, dynamic>>(
      '/vault/credentials/$id/',
      data: _toRequestData(data),
    );
    return Credential.fromJson(response.data!);
  }

  Future<void> deleteCredential(int id) async {
    await _client.delete<void>('/vault/credentials/$id/');
  }

  Future<List<Category>> getCategories() async {
    final response = await _client.get<dynamic>('/vault/categories/');
    return _extractList(response.data)
        .cast<Map<String, dynamic>>()
        .map(Category.fromJson)
        .toList();
  }

  Future<Category> createCategory(String name) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/vault/categories/',
      data: {'name': name},
    );
    return Category.fromJson(response.data!);
  }

  Future<Category> updateCategory(int id, String name) async {
    final response = await _client.put<Map<String, dynamic>>(
      '/vault/categories/$id/',
      data: {'name': name},
    );
    return Category.fromJson(response.data!);
  }

  Future<void> deleteCategory(int id) async {
    await _client.delete<void>('/vault/categories/$id/');
  }

  /// Converts a plain data map from the UI layer into the format expected
  /// by the backend serializer, which uses `_input` suffixed field names
  /// for encrypted fields (username, password, url, notes).
  Map<String, dynamic> _toRequestData(Map<String, dynamic> data) {
    final result = <String, dynamic>{};
    for (final entry in data.entries) {
      switch (entry.key) {
        case 'username':
          result['username_input'] = entry.value;
        case 'password':
          result['password_input'] = entry.value;
        case 'url':
          result['url_input'] = entry.value;
        case 'notes':
          result['notes_input'] = entry.value;
        default:
          result[entry.key] = entry.value;
      }
    }
    return result;
  }

  /// Extracts a list from a DRF response that may be paginated or a plain list.
  static List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    return (data as Map<String, dynamic>)['results'] as List? ?? [];
  }
}
