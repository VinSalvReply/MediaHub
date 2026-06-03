import 'package:flutter/foundation.dart';
import 'package:mediahub/data/repositories/user_repository.dart';
import 'package:mediahub/features/users/models/content_item.dart';
import 'package:mediahub/features/users/models/event.dart';
import 'package:mediahub/features/users/models/user.dart';

class EventsController extends ChangeNotifier {
  final UserRepository _repository;

  EventsController({UserRepository? repository})
    : _repository = repository ?? UserRepository();

  List<User> users = [];
  List<Event> events = [];

  bool isLoadingUsers = false;
  bool isLoadingEvents = false;
  bool isMutating = false;
  String? error;

  Future<void> init() async {
    try {
      isLoadingUsers = true;
      notifyListeners();
      users = await _repository.getUsers();
    } catch (e) {
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
      events = await _repository.getGlobalEvents();
      events.sort((a, b) => a.date.compareTo(b.date));
    } catch (e) {
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
    List<ContentItem> contents = const [],
  }) async {
    return _mutate(() async {
      await _repository.createGlobalEvent(
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
    List<ContentItem> contents = const [],
  }) async {
    return _mutate(() async {
      await _repository.updateGlobalEvent(
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
      await _repository.updateGlobalEvent(
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
      await _repository.deleteGlobalEvent(event.id);
    });
  }

  Future<bool> _mutate(Future<void> Function() action) async {
    try {
      isMutating = true;
      notifyListeners();
      await action();
      await loadEvents();
      return true;
    } catch (e) {
      error = 'Operazione fallita';
      notifyListeners();
      return false;
    } finally {
      isMutating = false;
      notifyListeners();
    }
  }
}
