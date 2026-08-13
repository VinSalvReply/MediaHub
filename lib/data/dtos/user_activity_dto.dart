class UserActivityDto {
  final String type;
  final String description;
  final String date;

  const UserActivityDto({
    required this.type,
    required this.description,
    required this.date,
  });

  factory UserActivityDto.fromJson(Map<String, dynamic> json) {
    return UserActivityDto(
      type: json['type'] as String,
      description: json['description'] as String,
      date: json['date'] as String,
    );
  }
}
