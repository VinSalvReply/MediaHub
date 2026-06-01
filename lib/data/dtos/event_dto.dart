class EventDto {
  final int id;
  final String title;
  final String date;
  final int attendees;
  final String status;
  final int? userId;

  EventDto({
    required this.id,
    required this.title,
    required this.date,
    required this.attendees,
    required this.status,
    required this.userId,
  });

  factory EventDto.fromJson(Map<String, dynamic> json) {
    return EventDto(
      id: json['id'] as int,
      title: json['title'] as String,
      date: json['date'] as String,
      attendees: (json['attendees'] as num?)?.toInt() ?? 0,
      status: (json['status'] as String?) ?? 'upcoming',
      userId: (json['user_id'] as num?)?.toInt(),
    );
  }
}
