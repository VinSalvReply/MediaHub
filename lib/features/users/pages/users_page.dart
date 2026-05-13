import 'package:flutter/material.dart';
import 'package:mediahub/features/users/controllers/users_controller.dart';
import 'package:mediahub/features/users/widgets/users_list.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  late UsersController controller;

  @override
  void initState() {
    super.initState();
    controller = UsersController();
    controller.fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error != null) {
          return Center(child: Text(controller.error!));
        }

        return UsersList(users: controller.users);
      },
    );
  }
}
