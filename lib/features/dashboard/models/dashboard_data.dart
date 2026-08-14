/// Aggregates the dashboard payload returned by the API.
class DashboardData {
  final DashboardMetrics metrics;
  final List<DashboardActivity> activities;
  final List<DashboardInsight> insights;
  final List<DashboardTrendPoint> trend;
  final List<DashboardAlert> alerts;
  final List<DashboardFocusEvent> focusEvents;

  const DashboardData({
    required this.metrics,
    required this.activities,
    required this.insights,
    required this.trend,
    required this.alerts,
    required this.focusEvents,
  });
}

// ================= METRICS =================

/// Summary metrics displayed on the dashboard header and cards.
class DashboardMetrics {
  final int totalEvents;
  final int liveEvents;
  final int upcomingThisWeek;
  final int totalContents;
  final int publishedContents;
  final int totalMediaAssets;
  final int eventsWithoutContents;

  const DashboardMetrics({
    required this.totalEvents,
    required this.liveEvents,
    required this.upcomingThisWeek,
    required this.totalContents,
    required this.publishedContents,
    required this.totalMediaAssets,
    required this.eventsWithoutContents,
  });
}

// ================= ACTIVITY =================

/// A single entry in the dashboard activity feed.
class DashboardActivity {
  final String title;
  final String subtitle;
  final String type;
  final DateTime date;

  const DashboardActivity({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.date,
  });
}

// ================= INSIGHTS =================

/// A single summary item shown by the dashboard insights panel.
class DashboardInsight {
  final String label;
  final double value;

  const DashboardInsight({required this.label, required this.value});
}

// ================= TREND =================

/// A point in a trend chart for activity over time.
class DashboardTrendPoint {
  final DateTime date;
  final int activeUsers;
  final int contentCreated;

  const DashboardTrendPoint({
    required this.date,
    required this.activeUsers,
    required this.contentCreated,
  });
}

// ================= ALERT =================

/// A flag that highlights an issue or important event in the dashboard.
class DashboardAlert {
  final String type;
  final String message;

  const DashboardAlert({required this.type, required this.message});
}

// ================= FOCUS EVENTS =================

/// An event that needs special attention in the main dashboard overview.
class DashboardFocusEvent {
  final String title;
  final DateTime date;
  final String status;
  final int contentCount;
  final int publishedCount;
  final int mediaCount;
  final bool needsAttention;

  const DashboardFocusEvent({
    required this.title,
    required this.date,
    required this.status,
    required this.contentCount,
    required this.publishedCount,
    required this.mediaCount,
    required this.needsAttention,
  });
}
