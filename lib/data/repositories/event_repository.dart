import 'package:mediahub/data/dtos/event_dto.dart';
import 'package:mediahub/data/mappers/event_mapper.dart';
import 'package:mediahub/data/services/event_service.dart';
import 'package:mediahub/features/events/models/event.dart';

/// Repository responsible for loading and mutating events.
class EventRepository {
  final EventService _eventService;

  EventRepository({EventService? eventService})
    : _eventService = eventService ?? EventService();

  Future<List<Event>> getUserEvents(int userId) async {
    final List<Map<String, dynamic>> response = await _eventService
        .getUserEvents(userId);
    return _toEvents(response);
  }

  Future<Event> createUserEvent(int userId, Event event) async {
    final Map<String, dynamic> response = await _eventService.addUserEvent(
      userId,
      event.toJson(),
    );
    return _toEvent(response);
  }

  Future<Event> updateUserEvent(int userId, Event event) async {
    final Map<String, dynamic> response = await _eventService.updateUserEvent(
      userId,
      event.id,
      event.toJson(),
    );
    return _toEvent(response);
  }

  Future<void> deleteUserEvent(int userId, int eventId) {
    return _eventService.deleteUserEvent(userId, eventId);
  }

  Future<List<Event>> getGlobalEvents({int? userId}) async {
    final List<Map<String, dynamic>> response = await _eventService.getEvents(
      userId: userId,
    );
    return _toEvents(response);
  }

  Future<Event> createGlobalEvent(Event event) async {
    final Map<String, dynamic> response = await _eventService.addEvent(
      event.toJson(),
    );
    return _toEvent(response);
  }

  Future<Event> updateGlobalEvent(Event event) async {
    final Map<String, dynamic> response = await _eventService.updateEvent(
      event.id,
      event.toJson(),
    );
    return _toEvent(response);
  }

  Future<void> deleteGlobalEvent(int eventId) {
    return _eventService.deleteEvent(eventId);
  }

  List<Event> _toEvents(List<Map<String, dynamic>> response) {
    return response.map(_toEvent).toList();
  }

  Event _toEvent(Map<String, dynamic> json) {
    return EventDto.fromJson(json).toModel();
  }
}
