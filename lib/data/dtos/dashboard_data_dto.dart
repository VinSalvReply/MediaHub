class DashboardDataDto {
  final DashboardMetricsDto metrics;
  final List<DashboardActivityDto> activities;
  final List<DashboardInsightDto> insights;
  final List<DashboardTrendDto> trend;
  final List<DashboardAlertDto> alerts;
  final List<DashboardFocusEventDto> focusEvents;

  const DashboardDataDto({
    required this.metrics,
    required this.activities,
    required this.insights,
    required this.trend,
    required this.alerts,
    required this.focusEvents,
  });

  factory DashboardDataDto.fromJson(Map<String, dynamic> json) {
    return DashboardDataDto(
      metrics: DashboardMetricsDto.fromJson(
        json['metrics'] as Map<String, dynamic>,
      ),
      activities: (json['activities'] as List<dynamic>)
          .map(
            (dynamic j) =>
                DashboardActivityDto.fromJson(j as Map<String, dynamic>),
          )
          .toList(),
      insights: (json['insights'] as List<dynamic>)
          .map(
            (dynamic j) =>
                DashboardInsightDto.fromJson(j as Map<String, dynamic>),
          )
          .toList(),
      trend: (json['trend'] as List<dynamic>)
          .map(
            (dynamic j) =>
                DashboardTrendDto.fromJson(j as Map<String, dynamic>),
          )
          .toList(),
      alerts: (json['alerts'] as List<dynamic>)
          .map(
            (dynamic j) =>
                DashboardAlertDto.fromJson(j as Map<String, dynamic>),
          )
          .toList(),
      focusEvents: (json['focusEvents'] as List<dynamic>)
          .map(
            (dynamic j) =>
                DashboardFocusEventDto.fromJson(j as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class DashboardMetricsDto {
  final int totalEvents;
  final int liveEvents;
  final int upcomingThisWeek;
  final int totalContents;
  final int publishedContents;
  final int totalMediaAssets;
  final int eventsWithoutContents;

  const DashboardMetricsDto({
    required this.totalEvents,
    required this.liveEvents,
    required this.upcomingThisWeek,
    required this.totalContents,
    required this.publishedContents,
    required this.totalMediaAssets,
    required this.eventsWithoutContents,
  });

  factory DashboardMetricsDto.fromJson(Map<String, dynamic> json) {
    return DashboardMetricsDto(
      totalEvents: (json['totalEvents'] as num).toInt(),
      liveEvents: (json['liveEvents'] as num).toInt(),
      upcomingThisWeek: (json['upcomingThisWeek'] as num).toInt(),
      totalContents: (json['totalContents'] as num).toInt(),
      publishedContents: (json['publishedContents'] as num).toInt(),
      totalMediaAssets: (json['totalMediaAssets'] as num).toInt(),
      eventsWithoutContents: (json['eventsWithoutContents'] as num).toInt(),
    );
  }
}

class DashboardActivityDto {
  final String title;
  final String subtitle;
  final String type;
  final DateTime date;

  const DashboardActivityDto({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.date,
  });

  factory DashboardActivityDto.fromJson(Map<String, dynamic> json) {
    return DashboardActivityDto(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      type: json['type'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }
}

class DashboardInsightDto {
  final String label;
  final double value;

  const DashboardInsightDto({required this.label, required this.value});

  factory DashboardInsightDto.fromJson(Map<String, dynamic> json) {
    return DashboardInsightDto(
      label: json['label'] as String,
      value: (json['value'] as num).toDouble(),
    );
  }
}

class DashboardFocusEventDto {
  final String title;
  final DateTime date;
  final String status;
  final int contentCount;
  final int publishedCount;
  final int mediaCount;
  final bool needsAttention;

  const DashboardFocusEventDto({
    required this.title,
    required this.date,
    required this.status,
    required this.contentCount,
    required this.publishedCount,
    required this.mediaCount,
    required this.needsAttention,
  });

  factory DashboardFocusEventDto.fromJson(Map<String, dynamic> json) {
    return DashboardFocusEventDto(
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      contentCount: (json['contentCount'] as num).toInt(),
      publishedCount: (json['publishedCount'] as num).toInt(),
      mediaCount: (json['mediaCount'] as num).toInt(),
      needsAttention: json['needsAttention'] as bool,
    );
  }
}

class DashboardTrendDto {
  final DateTime date;
  final int activeUsers;
  final int contentCreated;

  const DashboardTrendDto({
    required this.date,
    required this.activeUsers,
    required this.contentCreated,
  });

  factory DashboardTrendDto.fromJson(Map<String, dynamic> json) {
    return DashboardTrendDto(
      date: DateTime.parse(json['date'] as String),
      activeUsers: (json['active_users'] as num).toInt(),
      contentCreated: (json['content_created'] as num).toInt(),
    );
  }
}

class DashboardAlertDto {
  final String type;
  final String message;

  const DashboardAlertDto({required this.type, required this.message});

  factory DashboardAlertDto.fromJson(Map<String, dynamic> json) {
    return DashboardAlertDto(
      type: json['type'] as String,
      message: json['message'] as String,
    );
  }
}
