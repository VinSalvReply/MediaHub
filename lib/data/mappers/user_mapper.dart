import 'package:mediahub/data/dto/user_dto.dart';
import 'package:mediahub/features/users/models/user.dart';

extension UserDtoMapper on UserDto {
  User toDomain() {
    return User(
      id: id,
      name: name,
      lastName: last_name,
      email: email,
      role: role,
      isActive: is_active,
      createdAt: DateTime.parse(created_at),
      lastLogin: last_login != null ? DateTime.parse(last_login!) : null,
      assignedEvents: assigned_events ?? [],
    );
  }
}
