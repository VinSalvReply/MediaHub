import 'package:flutter/foundation.dart';
import 'package:mediahub/data/repositories/event_repository.dart';
import 'package:mediahub/data/repositories/user_repository.dart';
import 'package:mediahub/features/contents/models/content_item.dart';
import 'package:mediahub/features/events/models/event.dart';
import 'package:mediahub/features/users/models/user.dart';

/// Manages event-related data and the associated users used in the events screen.
class EventsController extends ChangeNotifier {
  final UserRepository _repository;
  final EventRepository _eventRepository;

  EventsController({
    UserRepository? repository,
    EventRepository? eventRepository,
  }) : _repository = repository ?? UserRepository(),
       _eventRepository = eventRepository ?? EventRepository();

  List<User> users = const <User>[];
  List<Event> events = const <Event>[];

  bool isLoadingUsers = false;
  bool isLoadingEvents = false;
  bool isMutating = false;
  String? errorMessage;

  Future<void> init() async {
    try {
      isLoadingUsers = true;
      notifyListeners();
      users = await _repository.getUsers();
    } catch (error, stackTrace) {
      debugPrint('EventsController.init error: $error\n$stackTrace');
      errorMessage = 'Impossibile caricare gli utenti';
    } finally {
      isLoadingUsers = false;
      notifyListeners();
    }
    await loadEvents();
  }

  Future<void> loadEvents() async {
    try {
      isLoadingEvents = true;
      errorMessage = null;
      notifyListeners();
      events = await _eventRepository.getGlobalEvents();
      events.sort((Event a, Event b) => a.date.compareTo(b.date));
    } catch (error, stackTrace) {
      debugPrint('EventsController.loadEvents error: $error\n$stackTrace');
      errorMessage = 'Impossibile caricare gli eventi';
    } finally {
      isLoadingEvents = false;
      notifyListeners();
    }
  }

  Future<bool> addEvent({
    required String title,
    required DateTime date,
    required int attendees,
    required EventStatus status,
    List<ContentItem> contents = const <ContentItem>[],
  }) async {
    return _mutate(() async {
      await _eventRepository.createGlobalEvent(
        Event(
          id: 0,
          title: title,
          date: date,
          attendees: attendees,
          status: status,
          userId: null,
          contents: contents,
        ),
      );
    });
  }

  Future<bool> editEvent({
    required Event original,
    required String title,
    required DateTime date,
    required int attendees,
    required EventStatus status,
    List<ContentItem> contents = const <ContentItem>[],
  }) async {
    return _mutate(() async {
      await _eventRepository.updateGlobalEvent(
        Event(
          id: original.id,
          title: title,
          date: date,
          attendees: attendees,
          status: status,
          userId: original.userId,
          contents: contents,
        ),
      );
    });
  }

  Future<bool> assignEventToUser(Event event, int? userId) async {
    return _mutate(() async {
      await _eventRepository.updateGlobalEvent(
        Event(
          id: event.id,
          title: event.title,
          date: event.date,
          attendees: event.attendees,
          status: event.status,
          userId: userId,
          contents: event.contents,
        ),
      );
    });
  }

  Future<bool> removeEvent(Event event) async {
    return _mutate(() async {
      await _eventRepository.deleteGlobalEvent(event.id);
    });
  }

  Future<bool> _mutate(Future<void> Function() action) async {
    try {
      isMutating = true;
      notifyListeners();
      await action();
      await loadEvents();
      return true;
    } catch (error, stackTrace) {
      debugPrint('EventsController._mutate error: $error\n$stackTrace');
      errorMessage = 'Operazione fallita';
      notifyListeners();
      return false;
    } finally {
      isMutating = false;
      notifyListeners();
    }
  }
}
