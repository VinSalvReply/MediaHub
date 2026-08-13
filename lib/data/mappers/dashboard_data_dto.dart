import 'package:mediahub/data/dtos/dashboard_data_dto.dart';
import 'package:mediahub/features/dashboard/models/dashboard_data.dart';

class DashboardMapper {
  static DashboardData toDashboard(DashboardDataDto dto) {
    return DashboardData(
      metrics: DashboardMetrics(
        totalEvents: dto.metrics.totalEvents,
        liveEvents: dto.metrics.liveEvents,
        upcomingThisWeek: dto.metrics.upcomingThisWeek,
        totalContents: dto.metrics.totalContents,
        publishedContents: dto.metrics.publishedContents,
        totalMediaAssets: dto.metrics.totalMediaAssets,
        eventsWithoutContents: dto.metrics.eventsWithoutContents,
      ),
      activities: dto.activities
          .map(
            (DashboardActivityDto a) => DashboardActivity(
              title: a.title,
              subtitle: a.subtitle,
              type: a.type,
              date: a.date,
            ),
          )
          .toList(),
      insights: dto.insights
          .map((DashboardInsightDto i) => DashboardInsight(label: i.label, value: i.value))
          .toList(),
      trend: dto.trend
          .map(
            (DashboardTrendDto t) => DashboardTrendPoint(
              date: t.date,
              activeUsers: t.activeUsers,
              contentCreated: t.contentCreated,
            ),
          )
          .toList(),
      alerts: dto.alerts
          .map((DashboardAlertDto a) => DashboardAlert(type: a.type, message: a.message))
          .toList(),
      focusEvents: dto.focusEvents
          .map(
            (DashboardFocusEventDto f) => DashboardFocusEvent(
              title: f.title,
              date: f.date,
              status: f.status,
              contentCount: f.contentCount,
              publishedCount: f.publishedCount,
              mediaCount: f.mediaCount,
              needsAttention: f.needsAttention,
            ),
          )
          .toList(),
    );
  }
}
