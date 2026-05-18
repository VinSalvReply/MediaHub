import 'package:mediahub/features/dashboard/models/dashboard_data.dart';
import 'package:mediahub/data/dtos/dashboard_data_dto.dart';
import 'package:mediahub/features/users/models/user.dart';
import 'package:mediahub/features/users/models/user_activity.dart';
import 'package:mediahub/features/users/models/event.dart';
import 'package:mediahub/features/users/models/content_item.dart';

class DashboardMapper {
  static DashboardData toDashboard({
    required List<User> users,
    required List<UserActivity> activities,
    required List<Event> events,
    required List<ContentItem> contents,
    required List<DashboardTrendDto> trend,
    required List<DashboardAlertDto> alerts,
    required List<TopUserDto> topUsers,
  }) {
    final activeUsers = users.where((u) => u.isActive).length;

    return DashboardData(
      metrics: DashboardMetrics(
        totalUsers: users.length,
        activeUsers: activeUsers,
        events: events.length,
        content: contents.length,
        usersDelta: 0.12,
        activeDelta: 0.06,
      ),

      activities: activities.map((a) {
        return DashboardActivity(
          title: a.description,
          subtitle: a.type,
          type: a.type,
          date: a.date,
        );
      }).toList(),

      insights: [
        DashboardInsight(
          label: "Active users",
          value: activeUsers / users.length,
        ),
        DashboardInsight(label: "Content growth", value: contents.length / 300),
        DashboardInsight(label: "Events coverage", value: events.length / 50),
      ],

      trend: trend
          .map(
            (t) => DashboardTrendPoint(
              date: t.date,
              activeUsers: t.activeUsers,
              contentCreated: t.contentCreated,
            ),
          )
          .toList(),

      alerts: alerts
          .map((a) => DashboardAlert(type: a.type, message: a.message))
          .toList(),

      topUsers: topUsers
          .map((u) => TopUser(name: u.name, score: u.score))
          .toList(),
    );
  }
}
