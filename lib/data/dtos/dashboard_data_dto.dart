class DashboardDataDto {
  final DashboardMetricsDto metrics;
  final List<DashboardActivityDto> activities;
  final List<DashboardInsightDto> insights;
  final List<DashboardTrendDto> trend;
  final List<DashboardAlertDto> alerts;
  final List<DashboardFocusEventDto> focusEvents;

  DashboardDataDto({
    required this.metrics,
    required this.activities,
    required this.insights,
    required this.trend,
    required this.alerts,
    required this.focusEvents,
  });

  factory DashboardDataDto.fromJson(Map<String, dynamic> json) {
    return DashboardDataDto(
      metrics: DashboardMetricsDto.fromJson(json['metrics']),
        activities: (json['activities'] as List<dynamic>)
          .map((dynamic j) => DashboardActivityDto.fromJson(j as Map<String, dynamic>))
          .toList(),
        insights: (json['insights'] as List<dynamic>)
          .map((dynamic j) => DashboardInsightDto.fromJson(j as Map<String, dynamic>))
          .toList(),
        trend: (json['trend'] as List<dynamic>)
          .map((dynamic j) => DashboardTrendDto.fromJson(j as Map<String, dynamic>))
          .toList(),
        alerts: (json['alerts'] as List<dynamic>)
          .map((dynamic j) => DashboardAlertDto.fromJson(j as Map<String, dynamic>))
          .toList(),
        focusEvents: (json['focusEvents'] as List<dynamic>)
          .map((dynamic j) => DashboardFocusEventDto.fromJson(j as Map<String, dynamic>))
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

  DashboardMetricsDto({
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
      totalEvents: json['totalEvents'],
      liveEvents: json['liveEvents'],
      upcomingThisWeek: json['upcomingThisWeek'],
      totalContents: json['totalContents'],
      publishedContents: json['publishedContents'],
      totalMediaAssets: json['totalMediaAssets'],
      eventsWithoutContents: json['eventsWithoutContents'],
    );
  }
}

class DashboardActivityDto {
  final String title;
  final String subtitle;
  final String type;
  final DateTime date;

  DashboardActivityDto({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.date,
  });

  factory DashboardActivityDto.fromJson(Map<String, dynamic> json) {
    return DashboardActivityDto(
      title: json['title'],
      subtitle: json['subtitle'],
      type: json['type'],
      date: DateTime.parse(json['date']),
    );
  }
}

class DashboardInsightDto {
  final String label;
  final double value;

  DashboardInsightDto({required this.label, required this.value});

  factory DashboardInsightDto.fromJson(Map<String, dynamic> json) {
    return DashboardInsightDto(
      label: json['label'],
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

  DashboardFocusEventDto({
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
      title: json['title'],
      date: DateTime.parse(json['date']),
      status: json['status'],
      contentCount: json['contentCount'],
      publishedCount: json['publishedCount'],
      mediaCount: json['mediaCount'],
      needsAttention: json['needsAttention'],
    );
  }
}

class DashboardTrendDto {
  final DateTime date;
  final int activeUsers;
  final int contentCreated;

  DashboardTrendDto({
    required this.date,
    required this.activeUsers,
    required this.contentCreated,
  });

  factory DashboardTrendDto.fromJson(Map<String, dynamic> json) {
    return DashboardTrendDto(
      date: DateTime.parse(json["date"]),
      activeUsers: json["active_users"],
      contentCreated: json["content_created"],
    );
  }
}

class DashboardAlertDto {
  final String type;
  final String message;

  DashboardAlertDto({required this.type, required this.message});

  factory DashboardAlertDto.fromJson(Map<String, dynamic> json) {
    return DashboardAlertDto(type: json["type"], message: json["message"]);
  }
}
