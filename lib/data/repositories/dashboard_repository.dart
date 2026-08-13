import 'package:mediahub/data/dtos/dashboard_data_dto.dart';
import 'package:mediahub/data/mappers/dashboard_data_dto.dart';
import 'package:mediahub/data/services/dashboard_service.dart';
import 'package:mediahub/features/dashboard/models/dashboard_data.dart';

class DashboardRepository {
  final DashboardService _dashboardService;

  DashboardRepository({DashboardService? dashboardService})
    : _dashboardService = dashboardService ?? DashboardService();

  Future<DashboardData> getDashboard() async {
    final Map<String, dynamic> json = await _dashboardService.getDashboard();
    return DashboardMapper.toDashboard(DashboardDataDto.fromJson(json));
  }
}
