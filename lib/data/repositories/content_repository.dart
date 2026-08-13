import 'package:mediahub/data/dtos/content_item_dto.dart';
import 'package:mediahub/data/mappers/content_item_mapper.dart';
import 'package:mediahub/data/services/content_service.dart';
import 'package:mediahub/features/users/models/content_item.dart';

/// Repository responsible for loading and mutating content items.
class ContentRepository {
  final ContentService _contentService;

  ContentRepository({ContentService? contentService})
    : _contentService = contentService ?? ContentService();

  Future<List<ContentItem>> getUserContent(int userId) async {
    final List<Map<String, dynamic>> response = await _contentService
        .getUserContent(userId);
    return _toContents(response);
  }

  Future<List<ContentItem>> getGlobalContents({
    int? userId,
    int? eventId,
  }) async {
    final List<Map<String, dynamic>> response = await _contentService
        .getContents(userId: userId, eventId: eventId);
    return _toContents(response);
  }

  Future<ContentItem> createGlobalContent(ContentItem content) async {
    final Map<String, dynamic> response = await _contentService.addContent(
      content.toJson(),
    );
    return _toContent(response);
  }

  Future<ContentItem> updateGlobalContent(ContentItem content) async {
    final Map<String, dynamic> response = await _contentService.updateContent(
      content.id,
      content.toJson(),
    );
    return _toContent(response);
  }

  Future<void> deleteGlobalContent(int contentId) {
    return _contentService.deleteContent(contentId);
  }

  List<ContentItem> _toContents(List<Map<String, dynamic>> response) {
    return response.map(_toContent).toList();
  }

  ContentItem _toContent(Map<String, dynamic> json) {
    return ContentItemDto.fromJson(json).toModel();
  }
}
