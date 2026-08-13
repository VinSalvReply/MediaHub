import 'package:flutter/material.dart';
import 'package:mediahub/core/constants/color.dart';
import 'package:mediahub/core/constants/responsive.dart';
import 'package:mediahub/features/users/models/user.dart';
import 'package:mediahub/features/users/widgets/user_card.dart';
import 'package:mediahub/features/users/widgets/user_list_tile.dart';

class UsersList extends StatelessWidget {
  final List<User> users;

  const UsersList({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double screenWidth = constraints.maxWidth;
        final bool isMobile = ResponsiveBreakpoints.isMobile(screenWidth);
        final bool isTablet = ResponsiveBreakpoints.isTablet(screenWidth);

        // Su mobile: mostra lista verticale compatta
        if (isMobile) {
          return Scrollbar(
            thumbVisibility: true,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: users.length,
              itemBuilder: (BuildContext context, int index) {
                final User user = users[index];
                final Color baseColor = cardColors[index % cardColors.length];
                return UserListTile(user: user, color: baseColor, index: index);
              },
            ),
          );
        }

        // Su tablet e desktop: mostra grid con card
        late int crossAxisCount;
        late double mainAxisExtent;
        late double crossAxisSpacing;
        late double mainAxisSpacing;
        late EdgeInsets padding;

        if (isTablet) {
          crossAxisCount = 2;
          mainAxisExtent = 380;
          crossAxisSpacing = 16;
          mainAxisSpacing = 16;
          padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
        } else {
          // Desktop: 4-5 colonne per card più compatte
          crossAxisCount = screenWidth > 1600 ? 5 : 4;
          mainAxisExtent = 360;
          crossAxisSpacing = 16;
          mainAxisSpacing = 16;
          padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
        }

        return Scrollbar(
          thumbVisibility: true,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: padding,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: mainAxisSpacing,
              mainAxisExtent: mainAxisExtent,
            ),
            itemCount: users.length,
            itemBuilder: (BuildContext context, int index) {
              final User user = users[index];
              final Color baseColor = cardColors[index % cardColors.length];
              return UserCard(user: user, color: baseColor, index: index);
            },
          ),
        );
      },
    );
  }
}
