import 'package:mediahub/data/services/api_client.dart';

/// Servizio di accesso ai dati lato utenti/dashboard.
class UserService {
  final ApiClient _api;
  // In-memory cache scoped to the current service instance.
  final Map<String, _CacheEntry<dynamic>> _cache =
      <String, _CacheEntry<dynamic>>{};
  static const Duration _cacheTtl = Duration(minutes: 5);
  static const String _usersCacheKey = 'users';
  static const String _eventsCacheKey = 'events';
  static const String _contentsCacheKey = 'contents';
  static const String _dashboardCacheKey = 'dashboard';

  UserService({ApiClient? api}) : _api = api ?? ApiClient();

  // ================= USERS =================

  Future<List<Map<String, dynamic>>> getUsers() async {
    return _getCachedList(_usersCacheKey, '/users');
  }

  Future<Map<String, dynamic>> getUser(int userId) async {
    return _mapJson(await _api.get('/users/$userId'));
  }

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> body) async {
    return _mapJson(await _api.post('/users', body));
  }

  Future<Map<String, dynamic>> updateUser(
    int userId,
    Map<String, dynamic> body,
  ) async {
    return _mapJson(await _api.put('/users/$userId', body));
  }

  Future<void> deleteUser(int userId) => _api.delete('/users/$userId');

  // ================= ACTIVITY =================

  Future<List<Map<String, dynamic>>> getUserActivity(int userId) async {
    return _listJson(await _api.get('/users/$userId/activity'));
  }

  Future<Map<String, dynamic>> addUserActivity(
    int userId,
    Map<String, dynamic> body,
  ) async {
    return _mapJson(await _api.post('/users/$userId/activity', body));
  }

  // ================= EVENTS =================

  Future<List<Map<String, dynamic>>> getUserEvents(int userId) async {
    return _listJson(await _api.get('/users/$userId/events'));
  }

  Future<Map<String, dynamic>> addUserEvent(
    int userId,
    Map<String, dynamic> body,
  ) async {
    final Map<String, dynamic> result = _mapJson(
      await _api.post('/users/$userId/events', body),
    );
    _invalidateCache();
    return result;
  }

  Future<Map<String, dynamic>> updateUserEvent(
    int userId,
    int eventId,
    Map<String, dynamic> body,
  ) async {
    final Map<String, dynamic> result = _mapJson(
      await _api.put('/users/$userId/events/$eventId', body),
    );
    _invalidateCache();
    return result;
  }

  Future<void> deleteUserEvent(int userId, int eventId) async {
    await _api.delete('/users/$userId/events/$eventId');
    _invalidateCache();
  }

  Future<List<Map<String, dynamic>>> getEvents({int? userId}) async {
    if (userId == null) {
      return _getCachedList(_eventsCacheKey, '/events');
    }
    final String query = _buildQuery(<String, Object?>{'userId': userId});
    return _listJson(await _api.get('/events$query'));
  }

  Future<Map<String, dynamic>> addEvent(Map<String, dynamic> body) async {
    final Map<String, dynamic> result = _mapJson(
      await _api.post('/events', body),
    );
    _invalidateCache();
    return result;
  }

  Future<Map<String, dynamic>> updateEvent(
    int eventId,
    Map<String, dynamic> body,
  ) async {
    final Map<String, dynamic> result = _mapJson(
      await _api.put('/events/$eventId', body),
    );
    _invalidateCache();
    return result;
  }

  Future<void> deleteEvent(int eventId) async {
    await _api.delete('/events/$eventId');
    _invalidateCache();
  }

  // ================= CONTENT =================

  Future<List<Map<String, dynamic>>> getUserContent(int userId) async {
    return _listJson(await _api.get('/users/$userId/content'));
  }

  Future<Map<String, dynamic>> addUserContent(
    int userId,
    Map<String, dynamic> body,
  ) async {
    return _mapJson(await _api.post('/users/$userId/content', body));
  }

  Future<Map<String, dynamic>> updateUserContent(
    int userId,
    int itemId,
    Map<String, dynamic> body,
  ) async {
    return _mapJson(await _api.put('/users/$userId/content/$itemId', body));
  }

  Future<void> deleteUserContent(int userId, int itemId) =>
      _api.delete('/users/$userId/content/$itemId');

  Future<List<Map<String, dynamic>>> getContents({
    int? userId,
    int? eventId,
  }) async {
    if (userId == null && eventId == null) {
      return _getCachedList(_contentsCacheKey, '/contents');
    }
    final String query = _buildQuery(<String, Object?>{
      'userId': userId,
      'eventId': eventId,
    });
    return _listJson(await _api.get('/contents$query'));
  }

  Future<Map<String, dynamic>> addContent(Map<String, dynamic> body) async {
    return _mapJson(await _api.post('/contents', body));
  }

  Future<Map<String, dynamic>> updateContent(
    int contentId,
    Map<String, dynamic> body,
  ) async {
    return _mapJson(await _api.put('/contents/$contentId', body));
  }

  Future<void> deleteContent(int contentId) =>
      _api.delete('/contents/$contentId');

  // ================= DASHBOARD =================

  Future<Map<String, dynamic>> getDashboard() async {
    return _getCachedMap(_dashboardCacheKey, '/dashboard');
  }

  // ================= HELPERS =================

  List<Map<String, dynamic>> _listJson(dynamic raw) {
    return (raw as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Map<String, dynamic> _mapJson(dynamic raw) {
    return Map<String, dynamic>.from(raw as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> _getCachedList(
    String cacheKey,
    String path,
  ) async {
    final List<Map<String, dynamic>>? cached =
        _getCached<List<Map<String, dynamic>>>(cacheKey);
    if (cached != null) return cached;
    final List<Map<String, dynamic>> result = _listJson(await _api.get(path));
    _cacheResult(cacheKey, result);
    return result;
  }

  Future<Map<String, dynamic>> _getCachedMap(
    String cacheKey,
    String path,
  ) async {
    final Map<String, dynamic>? cached = _getCached<Map<String, dynamic>>(
      cacheKey,
    );
    if (cached != null) return cached;
    final Map<String, dynamic> result = _mapJson(await _api.get(path));
    _cacheResult(cacheKey, result);
    return result;
  }

  String _buildQuery(Map<String, Object?> params) {
    final Iterable<MapEntry<String, Object?>> entries = params.entries.where(
      (MapEntry<String, Object?> e) => e.value != null,
    );
    if (entries.isEmpty) return '';
    return '?${entries.map((MapEntry<String, Object?> e) => '${e.key}=${e.value}').join('&')}';
  }

  void _cacheResult<T>(String key, T value) {
    _cache[key] = _CacheEntry<T>(value, DateTime.now());
  }

  T? _getCached<T>(String key) {
    final _CacheEntry<dynamic>? entry = _cache[key];
    if (entry == null) return null;
    if (DateTime.now().difference(entry.timestamp) > _cacheTtl) {
      _cache.remove(key);
      return null;
    }
    return entry.value as T;
  }

  void _invalidateCache() {
    for (final String key in <String>[_eventsCacheKey, _dashboardCacheKey]) {
      _cache.remove(key);
    }
  }
}

class _CacheEntry<T> {
  final T value;
  final DateTime timestamp;

  _CacheEntry(this.value, this.timestamp);
}
