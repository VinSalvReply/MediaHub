import 'package:mediahub/data/services/api_client.dart';

/// HTTP service for users and their activity records.
class UserService {
  final ApiClient _api;
  final Map<String, _CacheEntry> _cache = <String, _CacheEntry>{};

  static const Duration _cacheTtl = Duration(minutes: 5);
  static const String _usersCacheKey = 'users';

  UserService({ApiClient? api}) : _api = api ?? ApiClient();

  Future<List<Map<String, dynamic>>> getUsers() async {
    final _CacheEntry? cached = _getCached(_usersCacheKey);
    if (cached != null) {
      return cached.value as List<Map<String, dynamic>>;
    }

    final List<Map<String, dynamic>> users = _listJson(
      await _api.get('/users'),
    );
    _cache[_usersCacheKey] = _CacheEntry(users, DateTime.now());
    return users;
  }

  Future<Map<String, dynamic>> getUser(int userId) async {
    return _mapJson(await _api.get('/users/$userId'));
  }

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> body) async {
    final Map<String, dynamic> user = _mapJson(await _api.post('/users', body));
    _invalidateUsersCache();
    return user;
  }

  Future<Map<String, dynamic>> updateUser(
    int userId,
    Map<String, dynamic> body,
  ) async {
    final Map<String, dynamic> user = _mapJson(
      await _api.put('/users/$userId', body),
    );
    _invalidateUsersCache();
    return user;
  }

  Future<void> deleteUser(int userId) async {
    await _api.delete('/users/$userId');
    _invalidateUsersCache();
  }

  Future<List<Map<String, dynamic>>> getUserActivity(int userId) async {
    return _listJson(await _api.get('/users/$userId/activity'));
  }

  Future<Map<String, dynamic>> addUserActivity(
    int userId,
    Map<String, dynamic> body,
  ) async {
    return _mapJson(await _api.post('/users/$userId/activity', body));
  }

  List<Map<String, dynamic>> _listJson(dynamic raw) {
    return (raw as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Map<String, dynamic> _mapJson(dynamic raw) {
    return Map<String, dynamic>.from(raw as Map<String, dynamic>);
  }

  _CacheEntry? _getCached(String key) {
    final _CacheEntry? entry = _cache[key];
    if (entry == null) return null;
    if (DateTime.now().difference(entry.timestamp) > _cacheTtl) {
      _cache.remove(key);
      return null;
    }
    return entry;
  }

  void _invalidateUsersCache() => _cache.remove(_usersCacheKey);
}

class _CacheEntry {
  final dynamic value;
  final DateTime timestamp;

  _CacheEntry(this.value, this.timestamp);
}
