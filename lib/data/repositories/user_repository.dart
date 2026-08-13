import 'package:mediahub/data/dtos/content_item_dto.dart';
import 'package:mediahub/data/dtos/user_activity_dto.dart';
import 'package:mediahub/data/dtos/user_dto.dart';
import 'package:mediahub/data/mappers/content_item_mapper.dart';
import 'package:mediahub/data/mappers/user_activity_mapper.dart';
import 'package:mediahub/data/mappers/user_mapper.dart';
import 'package:mediahub/data/repositories/event_repository.dart';
import 'package:mediahub/data/services/user_service.dart';
import 'package:mediahub/features/users/models/content_item.dart';
import 'package:mediahub/features/users/models/event.dart';
import 'package:mediahub/features/users/models/user.dart';
import 'package:mediahub/features/users/models/user_activity.dart';
import 'package:mediahub/features/users/models/user_detail_data.dart';

class UserRepository {
  final UserService _service = UserService();
  final EventRepository _eventRepository;

  UserRepository({EventRepository? eventRepository})
    : _eventRepository = eventRepository ?? EventRepository();

  Future<List<User>> getUsers() async {
    final List<Map<String, dynamic>> response = await _service.getUsers();

    return response
        .map((Map<String, dynamic> json) => UserDto.fromJson(json).toModel())
        .toList();
  }

  Future<User> getUser(int userId) async {
    final Map<String, dynamic> response = await _service.getUser(userId);
    return UserDto.fromJson(response).toModel();
  }

  Future<List<UserActivity>> getUserActivity(int userId) async {
    final List<Map<String, dynamic>> response = await _service.getUserActivity(
      userId,
    );

    return response
        .map(
          (Map<String, dynamic> json) =>
              UserActivityDto.fromJson(json).toModel(),
        )
        .toList();
  }

  Future<List<ContentItem>> getUserContent(int userId) async {
    final List<Map<String, dynamic>> response = await _service.getUserContent(
      userId,
    );

    return response
        .map(
          (Map<String, dynamic> json) =>
              ContentItemDto.fromJson(json).toModel(),
        )
        .toList();
  }

  Future<List<ContentItem>> getGlobalContents({
    int? userId,
    int? eventId,
  }) async {
    final List<Map<String, dynamic>> response = await _service.getContents(
      userId: userId,
      eventId: eventId,
    );
    return response
        .map(
          (Map<String, dynamic> json) =>
              ContentItemDto.fromJson(json).toModel(),
        )
        .toList();
  }

  Future<ContentItem> createGlobalContent(ContentItem content) async {
    final Map<String, dynamic> json = await _service.addContent(
      _contentToJson(content),
    );
    return ContentItemDto.fromJson(json).toModel();
  }

  Future<ContentItem> updateGlobalContent(ContentItem content) async {
    final Map<String, dynamic> json = await _service.updateContent(
      content.id,
      _contentToJson(content),
    );
    return ContentItemDto.fromJson(json).toModel();
  }

  Future<void> deleteGlobalContent(int contentId) =>
      _service.deleteContent(contentId);

  Map<String, dynamic> _contentToJson(ContentItem content) => <String, dynamic>{
    'title': content.title,
    'type': content.type,
    'status': content.status,
    'created_at': content.createdAt.toIso8601String(),
    'user_id': content.userId,
    'event_id': content.eventId,
    'media_urls': content.mediaUrls,
    'post_body': content.postBody,
    'cta_label': content.callToActionLabel,
    'cta_url': content.callToActionUrl,
    'tags': content.tags,
  };

  Future<UserDetailData> getUserDetail(int userId) async {
    final User user = await getUser(userId);
    final List<UserActivity> activities = await getUserActivity(userId);
    final List<Event> events = await _eventRepository.getUserEvents(userId);
    final List<ContentItem> eventContents = events
        .expand(
          (Event event) => event.contents.map(
            (ContentItem content) => ContentItem(
              id: content.id,
              title: content.title,
              type: content.type,
              status: content.status,
              createdAt: content.createdAt,
              userId: userId,
              eventId: event.id,
              mediaUrls: content.mediaUrls,
              postBody: content.postBody,
              callToActionLabel: content.callToActionLabel,
              callToActionUrl: content.callToActionUrl,
              tags: content.tags,
            ),
          ),
        )
        .toList();

    return UserDetailData(
      user: user,
      activities: activities,
      events: events,
      contents: eventContents,
    );
  }
}
