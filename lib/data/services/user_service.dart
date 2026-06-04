import 'package:mediahub/data/services/api_client.dart';

/// Servizio di accesso ai dati lato utenti/dashboard.
///
/// Espone le stesse firme della versione precedente (mock), così i repository
/// e i mapper esistenti continuano a funzionare senza modifiche.
class UserService {
  final ApiClient _api;
  final Map<String, _CacheEntry> _cache = {};
  static const Duration _cacheDuration = Duration(minutes: 5);

  UserService({ApiClient? api}) : _api = api ?? ApiClient();

  void _cacheResult(String key, dynamic value) {
    _cache[key] = _CacheEntry(value, DateTime.now());
  }

  dynamic _getCached(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    if (DateTime.now().difference(entry.timestamp) > _cacheDuration) {
      _cache.remove(key);
      return null;
    }
    return entry.value;
  }

  void clearCache() => _cache.clear();

  // ================= USERS =================

  Future<List<Map<String, dynamic>>> getUsers() async {
    final cached = _getCached('users');
    if (cached != null) return cached;
    final result = _listJson(await _api.get('/users'));
    _cacheResult('users', result);
    return result;
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
    return _mapJson(await _api.post('/users/$userId/events', body));
  }

  Future<Map<String, dynamic>> updateUserEvent(
    int userId,
    int eventId,
    Map<String, dynamic> body,
  ) async {
    return _mapJson(await _api.put('/users/$userId/events/$eventId', body));
  }

  Future<void> deleteUserEvent(int userId, int eventId) =>
      _api.delete('/users/$userId/events/$eventId');

  Future<List<Map<String, dynamic>>> getEvents({int? userId}) async {
    if (userId == null) {
      final cached = _getCached('events');
      if (cached != null) return cached;
      final query = '';
      final result = _listJson(await _api.get('/events$query'));
      _cacheResult('events', result);
      return result;
    }
    final query = '?userId=$userId';
    return _listJson(await _api.get('/events$query'));
  }

  Future<Map<String, dynamic>> addEvent(Map<String, dynamic> body) async {
    return _mapJson(await _api.post('/events', body));
  }

  Future<Map<String, dynamic>> updateEvent(
    int eventId,
    Map<String, dynamic> body,
  ) async {
    return _mapJson(await _api.put('/events/$eventId', body));
  }

  Future<void> deleteEvent(int eventId) => _api.delete('/events/$eventId');

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
      final cached = _getCached('contents');
      if (cached != null) return cached;
      final result = _listJson(await _api.get('/contents'));
      _cacheResult('contents', result);
      return result;
    }
    final params = <String>[];
    if (userId != null) params.add('userId=$userId');
    if (eventId != null) params.add('eventId=$eventId');
    final query = params.isEmpty ? '' : '?${params.join('&')}';
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

  Future<List<Map<String, dynamic>>> getUsageTrend() async {
    final cached = _getCached('trend');
    if (cached != null) return cached;
    final result = _listJson(await _api.get('/dashboard/trend'));
    _cacheResult('trend', result);
    return result;
  }

  Future<List<Map<String, dynamic>>> getAlerts() async {
    final cached = _getCached('alerts');
    if (cached != null) return cached;
    final result = _listJson(await _api.get('/dashboard/alerts'));
    _cacheResult('alerts', result);
    return result;
  }

  Future<List<Map<String, dynamic>>> getTopUsers() async {
    return _listJson(await _api.get('/dashboard/top-users'));
  }

  // ================= HELPERS =================

  List<Map<String, dynamic>> _listJson(dynamic raw) {
    return (raw as List).cast<Map<String, dynamic>>();
  }

  Map<String, dynamic> _mapJson(dynamic raw) {
    return Map<String, dynamic>.from(raw as Map);
  }
}

class _CacheEntry {
  final dynamic value;
  final DateTime timestamp;

  _CacheEntry(this.value, this.timestamp);
}
