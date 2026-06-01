enum EventStatus { upcoming, live, ended }

EventStatus eventStatusFromString(String value) {
  return EventStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => EventStatus.upcoming,
  );
}

class Event {
  final int id;
  final String title;
  final DateTime date;
  final int attendees;
  final EventStatus status;
  final int? userId;

  const Event({
    required this.id,
    required this.title,
    required this.date,
    this.attendees = 0,
    this.status = EventStatus.upcoming,
    this.userId,
  });
}
