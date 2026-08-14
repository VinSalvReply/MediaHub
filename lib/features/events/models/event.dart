import 'package:mediahub/features/contents/models/content_item.dart';

/// Represents an event entry in the application.
class Event {
  final int id;
  final String title;
  final DateTime date;
  final int attendees;
  final EventStatus status;
  final int? userId;
  final List<ContentItem> contents;

  const Event({
    required this.id,
    required this.title,
    required this.date,
    this.attendees = 0,
    this.status = EventStatus.upcoming,
    this.userId,
    this.contents = const <ContentItem>[],
  });
}

/// Represents an event and its associated content.
enum EventStatus { upcoming, live, ended }

/// Converts a string value from the backend into an [EventStatus].
EventStatus eventStatusFromString(String value) {
  return EventStatus.values.firstWhere(
    (EventStatus e) => e.name == value,
    orElse: () => EventStatus.upcoming,
  );
}
