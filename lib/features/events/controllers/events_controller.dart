import 'package:flutter/foundation.dart';
import 'package:mediahub/data/repositories/event_repository.dart';
import 'package:mediahub/data/repositories/user_repository.dart';
import 'package:mediahub/features/users/models/content_item.dart';
import 'package:mediahub/features/users/models/event.dart';
import 'package:mediahub/features/users/models/user.dart';

class EventsController extends ChangeNotifier {
  final UserRepository _repository;
  final EventRepository _eventRepository;

  EventsController({
    UserRepository? repository,
    EventRepository? eventRepository,
  }) : _repository = repository ?? UserRepository(),
       _eventRepository = eventRepository ?? EventRepository();

  List<User> users = <User>[];
  List<Event> events = <Event>[];

  bool isLoadingUsers = false;
  bool isLoadingEvents = false;
  bool isMutating = false;
  String? error;

  Future<void> init() async {
    try {
      isLoadingUsers = true;
      notifyListeners();
      users = await _repository.getUsers();
    } catch (e, st) {
      debugPrint('EventsController.init error: $e\n$st');
      error = 'Impossibile caricare gli utenti';
    } finally {
      isLoadingUsers = false;
      notifyListeners();
    }
    await loadEvents();
  }

  Future<void> loadEvents() async {
    try {
      isLoadingEvents = true;
      error = null;
      notifyListeners();
      events = await _eventRepository.getGlobalEvents();
      events.sort((Event a, Event b) => a.date.compareTo(b.date));
    } catch (e, st) {
      debugPrint('EventsController.loadEvents error: $e\n$st');
      error = 'Impossibile caricare gli eventi';
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
    } catch (e, st) {
      debugPrint('EventsController._mutate error: $e\n$st');
      error = 'Operazione fallita';
      notifyListeners();
      return false;
    } finally {
      isMutating = false;
      notifyListeners();
    }
  }
}
