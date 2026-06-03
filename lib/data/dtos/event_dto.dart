import 'package:mediahub/data/dtos/content_item_dto.dart';

class EventDto {
  final int id;
  final String title;
  final String date;
  final int attendees;
  final String status;
  final int? userId;
  final List<ContentItemDto> contents;

  EventDto({
    required this.id,
    required this.title,
    required this.date,
    required this.attendees,
    required this.status,
    required this.userId,
    required this.contents,
  });

  factory EventDto.fromJson(Map<String, dynamic> json) {
    final fallbackId = Object.hash(
      json['title'],
      json['date'],
      json['status'],
    ).abs();

    return EventDto(
      id: (json['id'] as num?)?.toInt() ?? fallbackId,
      title: (json['title'] as String?) ?? 'Evento senza titolo',
      date: (json['date'] as String?) ?? DateTime.now().toIso8601String(),
      attendees: (json['attendees'] as num?)?.toInt() ?? 0,
      status: (json['status'] as String?) ?? 'upcoming',
      userId: (json['user_id'] as num?)?.toInt(),
      contents: ((json['contents'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ContentItemDto.fromJson)
          .toList(),
    );
  }
}
