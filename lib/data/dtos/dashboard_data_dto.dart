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

class TopUserDto {
  final String name;
  final int score;

  TopUserDto({required this.name, required this.score});

  factory TopUserDto.fromJson(Map<String, dynamic> json) {
    return TopUserDto(name: json["name"], score: json["score"]);
  }
}
