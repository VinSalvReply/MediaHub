import 'package:mediahub/data/dtos/event_dto.dart';
import 'package:mediahub/data/mappers/event_mapper.dart';
import 'package:mediahub/data/services/user_service.dart';
import 'package:mediahub/features/users/models/content_item.dart';
import 'package:mediahub/features/users/models/event.dart';

/// Repository responsible for loading and mutating events.
class EventRepository {
  final UserService _service;

  EventRepository({UserService? service}) : _service = service ?? UserService();

  Future<List<Event>> getUserEvents(int userId) async {
    final List<Map<String, dynamic>> response = await _service.getUserEvents(
      userId,
    );
    return _toEvents(response);
  }

  Future<Event> createUserEvent(int userId, Event event) async {
    final Map<String, dynamic> response = await _service.addUserEvent(
      userId,
      _toJson(event),
    );
    return _toEvent(response);
  }

  Future<Event> updateUserEvent(int userId, Event event) async {
    final Map<String, dynamic> response = await _service.updateUserEvent(
      userId,
      event.id,
      _toJson(event),
    );
    return _toEvent(response);
  }

  Future<void> deleteUserEvent(int userId, int eventId) {
    return _service.deleteUserEvent(userId, eventId);
  }

  Future<List<Event>> getGlobalEvents({int? userId}) async {
    final List<Map<String, dynamic>> response = await _service.getEvents(
      userId: userId,
    );
    return _toEvents(response);
  }

  Future<Event> createGlobalEvent(Event event) async {
    final Map<String, dynamic> response = await _service.addEvent(
      _toJson(event),
    );
    return _toEvent(response);
  }

  Future<Event> updateGlobalEvent(Event event) async {
    final Map<String, dynamic> response = await _service.updateEvent(
      event.id,
      _toJson(event),
    );
    return _toEvent(response);
  }

  Future<void> deleteGlobalEvent(int eventId) {
    return _service.deleteEvent(eventId);
  }

  List<Event> _toEvents(List<Map<String, dynamic>> response) {
    return response.map(_toEvent).toList();
  }

  Event _toEvent(Map<String, dynamic> json) {
    return EventDto.fromJson(json).toModel();
  }

  Map<String, dynamic> _toJson(Event event) => <String, dynamic>{
    'title': event.title,
    'date': event.date.toIso8601String(),
    'attendees': event.attendees,
    'status': event.status.name,
    'user_id': event.userId,
    'contents': event.contents.map(_contentToJson).toList(),
  };

  Map<String, dynamic> _contentToJson(ContentItem content) => <String, dynamic>{
    'title': content.title,
    'type': content.type,
    'status': content.status,
    'created_at': content.createdAt.toIso8601String(),
    'user_id': content.userId,
    'event_id': content.eventId,
    'media_urls': content.mediaUrls,
    'post_body': content.postBody,
    'cta_label': content.callToActionLabel,
    'cta_url': content.callToActionUrl,
    'tags': content.tags,
  };
}
