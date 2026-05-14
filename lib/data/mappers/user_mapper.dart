import 'package:mediahub/data/dtos/user_dto.dart';
import 'package:mediahub/features/users/models/user.dart';

extension UserMapper on UserDto {
  User toModel() {
    return User(
      id: id,
      name: name,
      lastName: lastName,
      email: email,
      role: role,
      isActive: isActive,
      createdAt: DateTime.parse(createdAt),
      lastLogin: lastLogin != null ? DateTime.parse(lastLogin!) : null,
    );
  }
}
