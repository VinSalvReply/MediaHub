import 'package:mediahub/data/dtos/user_activity_dto.dart';
import 'package:mediahub/features/users/models/user_activity.dart';

extension UserActivityMapper on UserActivityDto {
  UserActivity toModel() {
    return UserActivity(
      type: type,
      description: description,
      date: DateTime.parse(date),
    );
  }
}
