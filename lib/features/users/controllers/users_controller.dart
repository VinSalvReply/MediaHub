import 'package:flutter/material.dart';
import 'package:mediahub/data/repositories/user_repository.dart';
import 'package:mediahub/features/users/models/user.dart';
import 'package:mediahub/features/users/models/user_detail_data.dart';

/// Controls loading and exposes the list of users.
class UsersController extends ChangeNotifier {
  final UserRepository _repository;

  UsersController({UserRepository? repository})
    : _repository = repository ?? UserRepository();

  List<User> users = const <User>[];
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchUsers() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      users = await _repository.getUsers();
    } catch (error, stackTrace) {
      debugPrint('UsersController.fetchUsers error: $error\n$stackTrace');
      errorMessage = 'Errore nel caricamento';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<UserDetailData> loadUserDetail(int userId) async {
    try {
      return await _repository.getUserDetail(userId);
    } catch (error, stackTrace) {
      debugPrint('UsersController.loadUserDetail error: $error\n$stackTrace');
      rethrow;
    }
  }
}
