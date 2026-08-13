import 'package:mediahub/data/services/api_client.dart';

/// HTTP service for dashboard data.
class DashboardService {
  final ApiClient _api;

  DashboardService({ApiClient? api}) : _api = api ?? ApiClient();

  Future<Map<String, dynamic>> getDashboard() async {
    final dynamic response = await _api.get('/dashboard');
    return Map<String, dynamic>.from(response as Map<String, dynamic>);
  }
}
