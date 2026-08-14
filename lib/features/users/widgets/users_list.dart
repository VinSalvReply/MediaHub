import 'package:flutter/material.dart';
import 'package:mediahub/core/constants/color.dart';
import 'package:mediahub/core/constants/responsive.dart';
import 'package:mediahub/features/users/models/user.dart';
import 'package:mediahub/features/users/widgets/user_card/user_card.dart';
import 'package:mediahub/features/users/widgets/user_list_tile/user_list_tile.dart';

class UsersList extends StatelessWidget {
  final List<User> users;

  const UsersList({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double availableWidth = constraints.maxWidth;

        if (ResponsiveBreakpoints.isMobile(availableWidth)) {
          return _buildMobileList();
        }

        return _buildDesktopGrid(availableWidth);
      },
    );
  }

  Widget _buildMobileList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: users.length,
      itemBuilder: (BuildContext context, int index) {
        final User user = users[index];
        return UserListTile(
          user: user,
          color: _colorForIndex(index),
          index: index,
        );
      },
    );
  }

  Widget _buildDesktopGrid(double availableWidth) {
    final _GridLayout layout = _GridLayout.fromWidth(availableWidth);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: layout.padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: layout.columnCount,
        crossAxisSpacing: layout.spacing,
        mainAxisSpacing: layout.spacing,
        mainAxisExtent: layout.itemHeight,
      ),
      itemCount: users.length,
      itemBuilder: (BuildContext context, int index) {
        final User user = users[index];
        return UserCard(user: user, color: _colorForIndex(index), index: index);
      },
    );
  }

  Color _colorForIndex(int index) {
    return cardColors[index % cardColors.length];
  }
}

/// Grid measurements are kept together to make breakpoint changes explicit.
class _GridLayout {
  static const double _desktopFiveColumnWidth = 1600;
  static const double _spacing = 16;
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: _spacing,
    vertical: 8,
  );

  final int columnCount;
  final double itemHeight;
  final double spacing;
  final EdgeInsets padding;

  const _GridLayout({
    required this.columnCount,
    required this.itemHeight,
    required this.spacing,
    required this.padding,
  });

  factory _GridLayout.fromWidth(double width) {
    if (ResponsiveBreakpoints.isTablet(width)) {
      return const _GridLayout(
        columnCount: 2,
        itemHeight: 380,
        spacing: _spacing,
        padding: _padding,
      );
    }

    return _GridLayout(
      columnCount: width > _desktopFiveColumnWidth ? 5 : 4,
      itemHeight: 360,
      spacing: _spacing,
      padding: _padding,
    );
  }
}
