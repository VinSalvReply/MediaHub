class UserActivityDto {
  final String type;
  final String description;
  final String date;

  UserActivityDto({
    required this.type,
    required this.description,
    required this.date,
  });

  factory UserActivityDto.fromJson(Map<String, dynamic> json) {
    return UserActivityDto(
      type: json['type'],
      description: json['description'],
      date: json['date'],
    );
  }
}
