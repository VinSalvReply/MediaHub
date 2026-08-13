import 'package:flutter/foundation.dart';
import 'package:mediahub/data/repositories/content_repository.dart';
import 'package:mediahub/data/repositories/event_repository.dart';
import 'package:mediahub/data/repositories/user_repository.dart';
import 'package:mediahub/features/users/models/content_item.dart';
import 'package:mediahub/features/users/models/event.dart';
import 'package:mediahub/features/users/models/user.dart';

class ContentsController extends ChangeNotifier {
  final UserRepository _repository;
  final EventRepository _eventRepository;
  final ContentRepository _contentRepository;

  ContentsController({
    UserRepository? repository,
    EventRepository? eventRepository,
    ContentRepository? contentRepository,
  }) : _repository = repository ?? UserRepository(),
       _eventRepository = eventRepository ?? EventRepository(),
       _contentRepository = contentRepository ?? ContentRepository();

  List<User> users = <User>[];
  List<Event> events = <Event>[];
  List<ContentItem> contents = <ContentItem>[];

  bool isLoadingMeta = false;
  bool isLoadingContents = false;
  bool isMutating = false;
  String? error;

  Future<void> init() async {
    try {
      isLoadingMeta = true;
      notifyListeners();
      users = await _repository.getUsers();
      events = await _eventRepository.getGlobalEvents();
    } catch (e, st) {
      debugPrint('ContentsController.init error: $e\n$st');
      error = 'Impossibile caricare metadati contenuti';
    } finally {
      isLoadingMeta = false;
      notifyListeners();
    }
    await loadContents();
  }

  Future<void> loadContents() async {
    try {
      isLoadingContents = true;
      error = null;
      notifyListeners();
      contents = await _contentRepository.getGlobalContents();
      contents.sort(
        (ContentItem a, ContentItem b) => b.createdAt.compareTo(a.createdAt),
      );
    } catch (e, st) {
      debugPrint('ContentsController.loadContents error: $e\n$st');
      error = 'Impossibile caricare i contenuti';
    } finally {
      isLoadingContents = false;
      notifyListeners();
    }
  }

  Future<bool> addContent({
    required String title,
    required String type,
    required String status,
    List<String> mediaUrls = const <String>[],
    String? postBody,
    String? callToActionLabel,
    String? callToActionUrl,
    List<String> tags = const <String>[],
  }) async {
    return _mutate(() async {
      await _contentRepository.createGlobalContent(
        ContentItem(
          id: 0,
          title: title,
          type: type,
          status: status,
          createdAt: DateTime.now(),
          userId: null,
          eventId: null,
          mediaUrls: mediaUrls,
          postBody: postBody,
          callToActionLabel: callToActionLabel,
          callToActionUrl: callToActionUrl,
          tags: tags,
        ),
      );
    });
  }

  Future<bool> editContent({
    required ContentItem original,
    required String title,
    required String type,
    required String status,
    List<String> mediaUrls = const <String>[],
    String? postBody,
    String? callToActionLabel,
    String? callToActionUrl,
    List<String> tags = const <String>[],
  }) async {
    return _mutate(() async {
      await _contentRepository.updateGlobalContent(
        ContentItem(
          id: original.id,
          title: title,
          type: type,
          status: status,
          createdAt: original.createdAt,
          userId: original.userId,
          eventId: original.eventId,
          mediaUrls: mediaUrls,
          postBody: postBody,
          callToActionLabel: callToActionLabel,
          callToActionUrl: callToActionUrl,
          tags: tags,
        ),
      );
    });
  }

  Future<bool> assignContentToEvent(ContentItem item, int? eventId) async {
    return _mutate(() async {
      await _contentRepository.updateGlobalContent(
        ContentItem(
          id: item.id,
          title: item.title,
          type: item.type,
          status: item.status,
          createdAt: item.createdAt,
          userId: item.userId,
          eventId: eventId,
          mediaUrls: item.mediaUrls,
          postBody: item.postBody,
          callToActionLabel: item.callToActionLabel,
          callToActionUrl: item.callToActionUrl,
          tags: item.tags,
        ),
      );
    });
  }

  Future<bool> removeContent(ContentItem content) async {
    return _mutate(() async {
      await _contentRepository.deleteGlobalContent(content.id);
    });
  }

  Future<bool> _mutate(Future<void> Function() action) async {
    try {
      isMutating = true;
      error = null;
      notifyListeners();
      await action();
      await loadContents();
      return true;
    } catch (e, st) {
      debugPrint('ContentsController._mutate error: $e\n$st');
      error = 'Operazione contenuto fallita';
      notifyListeners();
      return false;
    } finally {
      isMutating = false;
      notifyListeners();
    }
  }
}
