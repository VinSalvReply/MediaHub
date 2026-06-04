import 'package:mediahub/data/mappers/dashboard_data_dto.dart';
import 'package:mediahub/data/mappers/event_mapper.dart';
import 'package:mediahub/data/mappers/user_mapper.dart';
import 'package:mediahub/data/services/user_service.dart';
import 'package:mediahub/data/dtos/dashboard_data_dto.dart';
import 'package:mediahub/data/dtos/user_dto.dart';
import 'package:mediahub/data/dtos/event_dto.dart';
import 'package:mediahub/features/dashboard/models/dashboard_data.dart';

class DashboardRepository {
  final UserService _userService;

  DashboardRepository({UserService? userService})
    : _userService = userService ?? UserService();

  Future<DashboardData> getDashboard() async {
    final results = await Future.wait([
      _userService.getUsers(),
      _userService.getEvents(),
      _userService.getUsageTrend(),
      _userService.getAlerts(),
    ]);

    final usersJson = results[0] as List;
    final eventsJson = results[1] as List;
    final trendJson = results[2] as List;
    final alertsJson = results[3] as List;

    final users = usersJson.map((j) => UserDto.fromJson(j).toModel()).toList();

    final events = eventsJson
        .map((j) => EventDto.fromJson(j).toModel())
        .toList();

    final trend = trendJson.map((j) => DashboardTrendDto.fromJson(j)).toList();

    final alerts = alertsJson
        .map((j) => DashboardAlertDto.fromJson(j))
        .toList();

    return DashboardMapper.toDashboard(
      users: users,
      events: events,
      trend: trend,
      alerts: alerts,
    );
  }
}
