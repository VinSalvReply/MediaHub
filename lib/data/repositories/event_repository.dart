import 'package:mediahub/data/dtos/event_dto.dart';
import 'package:mediahub/data/mappers/content_item_mapper.dart';
import 'package:mediahub/data/mappers/event_mapper.dart';
import 'package:mediahub/data/services/user_service.dart';
import 'package:mediahub/features/users/models/content_item.dart';
import 'package:mediahub/features/users/models/event.dart';

/// Repository responsible for loading and mutating events.
class EventRepository {
  final UserService _userService;

  EventRepository({UserService? userService})
    : _userService = userService ?? UserService();

  Future<List<Event>> getUserEvents(int userId) async {
    final List<Map<String, dynamic>> response = await _userService
        .getUserEvents(userId);
    return _toEvents(response);
  }

  Future<Event> createUserEvent(int userId, Event event) async {
    final Map<String, dynamic> response = await _userService.addUserEvent(
      userId,
      _toJson(event),
    );
    return _toEvent(response);
  }

  Future<Event> updateUserEvent(int userId, Event event) async {
    final Map<String, dynamic> response = await _userService.updateUserEvent(
      userId,
      event.id,
      _toJson(event),
    );
    return _toEvent(response);
  }

  Future<void> deleteUserEvent(int userId, int eventId) {
    return _userService.deleteUserEvent(userId, eventId);
  }

  Future<List<Event>> getGlobalEvents({int? userId}) async {
    final List<Map<String, dynamic>> response = await _userService.getEvents(
      userId: userId,
    );
    return _toEvents(response);
  }

  Future<Event> createGlobalEvent(Event event) async {
    final Map<String, dynamic> response = await _userService.addEvent(
      _toJson(event),
    );
    return _toEvent(response);
  }

  Future<Event> updateGlobalEvent(Event event) async {
    final Map<String, dynamic> response = await _userService.updateEvent(
      event.id,
      _toJson(event),
    );
    return _toEvent(response);
  }

  Future<void> deleteGlobalEvent(int eventId) {
    return _userService.deleteEvent(eventId);
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
    'contents': event.contents
        .map((ContentItem content) => content.toJson())
        .toList(),
  };
}
