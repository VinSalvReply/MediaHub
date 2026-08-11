import 'package:mediahub/data/dtos/dashboard_data_dto.dart';
import 'package:mediahub/data/mappers/dashboard_data_dto.dart';
import 'package:mediahub/data/services/user_service.dart';
import 'package:mediahub/features/dashboard/models/dashboard_data.dart';

class DashboardRepository {
  final UserService _userService;

  DashboardRepository({UserService? userService})
    : _userService = userService ?? UserService();

  Future<DashboardData> getDashboard() async {
    final json = await _userService.getDashboard();
    return DashboardMapper.toDashboard(DashboardDataDto.fromJson(json));
  }
}
