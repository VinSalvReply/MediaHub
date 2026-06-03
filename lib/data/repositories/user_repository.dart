import 'package:mediahub/data/dtos/content_item_dto.dart';
import 'package:mediahub/data/dtos/event_dto.dart';
import 'package:mediahub/data/dtos/user_activity_dto.dart';
import 'package:mediahub/data/dtos/user_dto.dart';
import 'package:mediahub/data/mappers/content_item_mapper.dart';
import 'package:mediahub/data/mappers/event_mapper.dart';
import 'package:mediahub/data/mappers/user_activity_mapper.dart';
import 'package:mediahub/data/mappers/user_mapper.dart';
import 'package:mediahub/data/services/user_service.dart';
import 'package:mediahub/features/users/models/content_item.dart';
import 'package:mediahub/features/users/models/event.dart';
import 'package:mediahub/features/users/models/user.dart';
import 'package:mediahub/features/users/models/user_activity.dart';
import 'package:mediahub/features/users/models/user_detail_data.dart';

class UserRepository {
  final UserService _service = UserService();

  UserRepository();

  Future<List<User>> getUsers() async {
    final response = await _service.getUsers();

    return response.map((json) => UserDto.fromJson(json).toModel()).toList();
  }

  Future<User> getUser(int userId) async {
    final users = await getUsers();

    return users.firstWhere((user) => user.id == userId);
  }

  Future<List<UserActivity>> getUserActivity(int userId) async {
    final response = await _service.getUserActivity(userId);

    return response
        .map((json) => UserActivityDto.fromJson(json).toModel())
        .toList();
  }

  Future<List<Event>> getEvents(int userId) async {
    final response = await _service.getUserEvents(userId);

    return response.map((json) => EventDto.fromJson(json).toModel()).toList();
  }

  Future<Event> createEvent(int userId, Event event) async {
    final json = await _service.addUserEvent(userId, _eventToJson(event));
    return EventDto.fromJson(json).toModel();
  }

  Future<Event> updateEvent(int userId, Event event) async {
    final json = await _service.updateUserEvent(
      userId,
      event.id,
      _eventToJson(event),
    );
    return EventDto.fromJson(json).toModel();
  }

  Future<void> deleteEvent(int userId, int eventId) =>
      _service.deleteUserEvent(userId, eventId);

  Future<List<Event>> getGlobalEvents({int? userId}) async {
    final response = await _service.getEvents(userId: userId);
    return response.map((json) => EventDto.fromJson(json).toModel()).toList();
  }

  Future<Event> createGlobalEvent(Event event) async {
    final json = await _service.addEvent(_eventToJson(event));
    return EventDto.fromJson(json).toModel();
  }

  Future<Event> updateGlobalEvent(Event event) async {
    final json = await _service.updateEvent(event.id, _eventToJson(event));
    return EventDto.fromJson(json).toModel();
  }

  Future<void> deleteGlobalEvent(int eventId) => _service.deleteEvent(eventId);

  Map<String, dynamic> _eventToJson(Event event) => {
    'title': event.title,
    'date': event.date.toIso8601String(),
    'attendees': event.attendees,
    'status': event.status.name,
    'user_id': event.userId,
    'contents': event.contents.map(_contentToJson).toList(),
  };

  Future<List<ContentItem>> getUserContent(int userId) async {
    final response = await _service.getUserContent(userId);

    return response
        .map((json) => ContentItemDto.fromJson(json).toModel())
        .toList();
  }

  Future<List<ContentItem>> getGlobalContents({
    int? userId,
    int? eventId,
  }) async {
    final response = await _service.getContents(
      userId: userId,
      eventId: eventId,
    );
    return response
        .map((json) => ContentItemDto.fromJson(json).toModel())
        .toList();
  }

  Future<ContentItem> createGlobalContent(ContentItem content) async {
    final json = await _service.addContent(_contentToJson(content));
    return ContentItemDto.fromJson(json).toModel();
  }

  Future<ContentItem> updateGlobalContent(ContentItem content) async {
    final json = await _service.updateContent(
      content.id,
      _contentToJson(content),
    );
    return ContentItemDto.fromJson(json).toModel();
  }

  Future<void> deleteGlobalContent(int contentId) =>
      _service.deleteContent(contentId);

  Map<String, dynamic> _contentToJson(ContentItem content) => {
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
    final user = await getUser(userId);
    final activities = await getUserActivity(userId);
    final events = await getEvents(userId);
    final eventContents = events
        .expand(
          (event) => event.contents.map(
            (content) => ContentItem(
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
