class DashboardData {
  final DashboardMetrics metrics;
  final List<DashboardActivity> activities;
  final List<DashboardInsight> insights;
  final List<DashboardTrendPoint> trend;
  final List<DashboardAlert> alerts;
  final List<DashboardFocusEvent> focusEvents;

  DashboardData({
    required this.metrics,
    required this.activities,
    required this.insights,
    required this.trend,
    required this.alerts,
    required this.focusEvents,
  });
}

// ================= METRICS =================

class DashboardMetrics {
  final int totalEvents;
  final int liveEvents;
  final int upcomingThisWeek;
  final int totalContents;
  final int publishedContents;
  final int totalMediaAssets;
  final int eventsWithoutContents;

  DashboardMetrics({
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

class DashboardActivity {
  final String title;
  final String subtitle;
  final String type;
  final DateTime date;

  DashboardActivity({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.date,
  });
}

// ================= INSIGHTS =================

class DashboardInsight {
  final String label;
  final double value;

  DashboardInsight({required this.label, required this.value});
}

// ================= TREND =================

class DashboardTrendPoint {
  final DateTime date;
  final int activeUsers;
  final int contentCreated;

  DashboardTrendPoint({
    required this.date,
    required this.activeUsers,
    required this.contentCreated,
  });
}

// ================= ALERT =================

class DashboardAlert {
  final String type;
  final String message;

  DashboardAlert({required this.type, required this.message});
}

// ================= FOCUS EVENTS =================

class DashboardFocusEvent {
  final String title;
  final DateTime date;
  final String status;
  final int contentCount;
  final int publishedCount;
  final int mediaCount;
  final bool needsAttention;

  DashboardFocusEvent({
    required this.title,
    required this.date,
    required this.status,
    required this.contentCount,
    required this.publishedCount,
    required this.mediaCount,
    required this.needsAttention,
  });
}
