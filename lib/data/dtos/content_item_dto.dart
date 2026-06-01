class ContentItemDto {
  final int id;
  final String title;
  final String type;
  final String status;
  final String createdAt;
  final int? userId;
  final int? eventId;

  ContentItemDto({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.userId,
    required this.eventId,
  });

  factory ContentItemDto.fromJson(Map<String, dynamic> json) {
    return ContentItemDto(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      status: (json['status'] as String?) ?? 'draft',
      createdAt: json['created_at'],
      userId: (json['user_id'] as num?)?.toInt(),
      eventId: (json['event_id'] as num?)?.toInt(),
    );
  }
}
