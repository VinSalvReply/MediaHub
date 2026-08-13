import 'package:mediahub/data/dtos/user_activity_dto.dart';
import 'package:mediahub/data/dtos/user_dto.dart';
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
  final UserService _userService;
  final EventRepository _eventRepository;

  UserRepository({UserService? userService, EventRepository? eventRepository})
    : _userService = userService ?? UserService(),
      _eventRepository = eventRepository ?? EventRepository();

  Future<List<User>> getUsers() async {
    final List<Map<String, dynamic>> response = await _userService.getUsers();

    return response
        .map((Map<String, dynamic> json) => UserDto.fromJson(json).toModel())
        .toList();
  }

  Future<User> getUser(int userId) async {
    final Map<String, dynamic> response = await _userService.getUser(userId);
    return UserDto.fromJson(response).toModel();
  }

  Future<List<UserActivity>> getUserActivity(int userId) async {
    final List<Map<String, dynamic>> response = await _userService
        .getUserActivity(userId);

    return response
        .map(
          (Map<String, dynamic> json) =>
              UserActivityDto.fromJson(json).toModel(),
        )
        .toList();
  }

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
