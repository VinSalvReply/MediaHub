import 'package:flutter/material.dart';
import 'package:mediahub/data/repositories/user_repository.dart';
import 'package:mediahub/features/users/models/user.dart';

class UsersController extends ChangeNotifier {
  final UserRepository repository = UserRepository();

  UsersController();

  List<User> users = <User>[];
  bool isLoading = false;
  String? error;

  Future<void> fetchUsers() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      users = await repository.getUsers();
    } catch (e, st) {
      debugPrint('UsersController.fetchUsers error: $e\n$st');
      error = "Errore nel caricamento";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
