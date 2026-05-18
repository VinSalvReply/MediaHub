class DashboardData {
  final DashboardMetrics metrics;
  final List<DashboardActivity> activities;
  final List<DashboardInsight> insights;
  final List<DashboardTrendPoint> trend;
  final List<DashboardAlert> alerts;
  final List<TopUser> topUsers;

  DashboardData({
    required this.metrics,
    required this.activities,
    required this.insights,
    required this.trend,
    required this.alerts,
    required this.topUsers,
  });
}

// ================= METRICS =================

class DashboardMetrics {
  final int totalUsers;
  final int activeUsers;
  final int events;
  final int content;
  final double usersDelta;
  final double activeDelta;

  DashboardMetrics({
    required this.totalUsers,
    required this.activeUsers,
    required this.events,
    required this.content,
    required this.usersDelta,
    required this.activeDelta,
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

// ================= TOP USERS =================

class TopUser {
  final String name;
  final int score;

  TopUser({required this.name, required this.score});
}
