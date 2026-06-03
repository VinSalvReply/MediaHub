import 'package:flutter/foundation.dart';
import 'package:mediahub/data/repositories/user_repository.dart';
import 'package:mediahub/features/users/models/content_item.dart';
import 'package:mediahub/features/users/models/event.dart';
import 'package:mediahub/features/users/models/user.dart';

class ContentsController extends ChangeNotifier {
  final UserRepository _repository;

  ContentsController({UserRepository? repository})
    : _repository = repository ?? UserRepository();

  List<User> users = [];
  List<Event> events = [];
  List<ContentItem> contents = [];

  bool isLoadingMeta = false;
  bool isLoadingContents = false;
  bool isMutating = false;
  String? error;

  Future<void> init() async {
    try {
      isLoadingMeta = true;
      notifyListeners();
      users = await _repository.getUsers();
      events = await _repository.getGlobalEvents();
    } catch (_) {
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
      contents = await _repository.getGlobalContents();
      contents.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      error = 'Impossibile caricare i contenuti';
    } finally {
      isLoadingContents = false;
      notifyListeners();
    }
  }

  Future<void> addContent({
    required String title,
    required String type,
    required String status,
    List<String> mediaUrls = const [],
    String? postBody,
    String? callToActionLabel,
    String? callToActionUrl,
    List<String> tags = const [],
  }) async {
    await _mutate(() async {
      await _repository.createGlobalContent(
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

  Future<void> editContent({
    required ContentItem original,
    required String title,
    required String type,
    required String status,
    List<String> mediaUrls = const [],
    String? postBody,
    String? callToActionLabel,
    String? callToActionUrl,
    List<String> tags = const [],
  }) async {
    await _mutate(() async {
      await _repository.updateGlobalContent(
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

  Future<void> assignContentToEvent(ContentItem item, int? eventId) async {
    await _mutate(() async {
      await _repository.updateGlobalContent(
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

  Future<void> removeContent(ContentItem content) async {
    await _mutate(() async {
      await _repository.deleteGlobalContent(content.id);
    });
  }

  Future<void> _mutate(Future<void> Function() action) async {
    try {
      isMutating = true;
      notifyListeners();
      await action();
      await loadContents();
    } catch (_) {
      error = 'Operazione contenuto fallita';
      notifyListeners();
    } finally {
      isMutating = false;
      notifyListeners();
    }
  }
}
