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

  Future<List<ContentItem>> getUserContent(int userId) async {
    final response = await _service.getUserContent(userId);

    return response
        .map((json) => ContentItemDto.fromJson(json).toModel())
        .toList();
  }

  Future<UserDetailData> getUserDetail(int userId) async {
    return UserDetailData(
      user: await getUser(userId),
      activities: await getUserActivity(userId),
      events: await getEvents(userId),
      contents: await getUserContent(userId),
    );
  }
}
