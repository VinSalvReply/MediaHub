import 'package:mediahub/data/dtos/content_item_dto.dart';
import 'package:mediahub/data/mappers/content_item_mapper.dart';
import 'package:mediahub/data/services/user_service.dart';
import 'package:mediahub/features/users/models/content_item.dart';

/// Repository responsible for loading and mutating content items.
class ContentRepository {
  final UserService _userService;

  ContentRepository({UserService? userService})
    : _userService = userService ?? UserService();

  Future<List<ContentItem>> getUserContent(int userId) async {
    final List<Map<String, dynamic>> response = await _userService
        .getUserContent(userId);
    return _toContents(response);
  }

  Future<List<ContentItem>> getGlobalContents({
    int? userId,
    int? eventId,
  }) async {
    final List<Map<String, dynamic>> response = await _userService.getContents(
      userId: userId,
      eventId: eventId,
    );
    return _toContents(response);
  }

  Future<ContentItem> createGlobalContent(ContentItem content) async {
    final Map<String, dynamic> response = await _userService.addContent(
      content.toJson(),
    );
    return _toContent(response);
  }

  Future<ContentItem> updateGlobalContent(ContentItem content) async {
    final Map<String, dynamic> response = await _userService.updateContent(
      content.id,
      content.toJson(),
    );
    return _toContent(response);
  }

  Future<void> deleteGlobalContent(int contentId) {
    return _userService.deleteContent(contentId);
  }

  List<ContentItem> _toContents(List<Map<String, dynamic>> response) {
    return response.map(_toContent).toList();
  }

  ContentItem _toContent(Map<String, dynamic> json) {
    return ContentItemDto.fromJson(json).toModel();
  }
}
