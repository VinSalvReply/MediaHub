class EventDto {
  final int id;
  final String title;
  final String date;

  EventDto({required this.id, required this.title, required this.date});

  factory EventDto.fromJson(Map<String, dynamic> json) {
    return EventDto(id: json['id'], title: json['title'], date: json['date']);
  }
}
