import 'package:flutter/material.dart';
import 'package:mediahub/core/constants/color.dart';
import 'package:mediahub/features/users/models/user.dart';
import 'package:mediahub/features/users/widgets/user_card.dart';

class UsersList extends StatelessWidget {
  final List<User> users;

  const UsersList({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 320,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 380,
            ),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final baseColor = cardColors[index % cardColors.length];

              return UserCard(user: user, color: baseColor, index: index);
            },
          );
        },
      ),
    );
  }
}
