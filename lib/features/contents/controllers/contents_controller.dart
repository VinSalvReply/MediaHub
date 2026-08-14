import 'package:flutter/foundation.dart';
import 'package:mediahub/data/dtos/media_upload_result.dart';
import 'package:mediahub/data/repositories/content_repository.dart';
import 'package:mediahub/data/repositories/event_repository.dart';
import 'package:mediahub/data/repositories/user_repository.dart';
import 'package:mediahub/features/users/models/content_item.dart';
import 'package:mediahub/features/users/models/event.dart';
import 'package:mediahub/features/users/models/user.dart';

/// Manages content-related data and user/event metadata used in the contents view.
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

  List<User> users = const <User>[];
  List<Event> events = const <Event>[];
  List<ContentItem> contents = const <ContentItem>[];

  bool isLoadingMeta = false;
  bool isLoadingContents = false;
  bool isMutating = false;
  String? errorMessage;

  Future<void> init() async {
    try {
      isLoadingMeta = true;
      notifyListeners();
      users = await _repository.getUsers();
      events = await _eventRepository.getGlobalEvents();
    } catch (error, stackTrace) {
      debugPrint('ContentsController.init error: $error\n$stackTrace');
      errorMessage = 'Impossibile caricare metadati contenuti';
    } finally {
      isLoadingMeta = false;
      notifyListeners();
    }
    await loadContents();
  }

  Future<void> loadContents() async {
    try {
      isLoadingContents = true;
      errorMessage = null;
      notifyListeners();
      contents = await _contentRepository.getGlobalContents();
      contents.sort(
        (ContentItem a, ContentItem b) => b.createdAt.compareTo(a.createdAt),
      );
    } catch (error, stackTrace) {
      debugPrint('ContentsController.loadContents error: $error\n$stackTrace');
      errorMessage = 'Impossibile caricare i contenuti';
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

  Future<MediaUploadResult> uploadMedia({
    Uint8List? bytes,
    String? fileName,
    String? filePath,
  }) async {
    try {
      return await _contentRepository.uploadMedia(
        bytes: bytes,
        fileName: fileName,
        filePath: filePath,
      );
    } catch (error, stackTrace) {
      debugPrint('ContentsController.uploadMedia error: $error\n$stackTrace');
      rethrow;
    }
  }

  Future<MediaUploadResult> importMedia(String sourceUrl) async {
    try {
      return await _contentRepository.importMedia(sourceUrl);
    } catch (error, stackTrace) {
      debugPrint('ContentsController.importMedia error: $error\n$stackTrace');
      rethrow;
    }
  }

  Future<bool> _mutate(Future<void> Function() action) async {
    try {
      isMutating = true;
      errorMessage = null;
      notifyListeners();
      await action();
      await loadContents();
      return true;
    } catch (error, stackTrace) {
      debugPrint('ContentsController._mutate error: $error\n$stackTrace');
      errorMessage = 'Operazione contenuto fallita';
      notifyListeners();
      return false;
    } finally {
      isMutating = false;
      notifyListeners();
    }
  }
}
