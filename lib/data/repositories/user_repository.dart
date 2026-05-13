import 'package:mediahub/data/dto/user_dto.dart';
import 'package:mediahub/data/mappers/user_mapper.dart';
import 'package:mediahub/data/services/user_service.dart';
import 'package:mediahub/features/users/models/user.dart';

class UserRepository {
  final UserService _service = UserService();

  UserRepository();

  Future<List<User>> getUsers() async {
    final response = await _service.getUsers();

    return response.map((json) => UserDto.fromJson(json).toDomain()).toList();
  }
}
