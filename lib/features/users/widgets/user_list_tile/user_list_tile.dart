import 'package:flutter/material.dart';
import 'package:mediahub/core/constants/animation.dart';
import 'package:mediahub/core/constants/responsive.dart';
import 'package:mediahub/core/utils/preserved_tween_animation_builder.dart';
import 'package:mediahub/features/users/models/user.dart';
import 'package:mediahub/features/users/widgets/user_detail/user_detail_route.dart';
import 'package:mediahub/features/users/widgets/user_list_tile/user_list_tile_content.dart';

/// Interactive compact user item used by the mobile users list.
class UserListTile extends StatefulWidget {
  final User user;
  final Color color;
  final int index;

  const UserListTile({
    super.key,
    required this.user,
    required this.color,
    required this.index,
  });

  @override
  State<UserListTile> createState() => _UserListTileState();
}

class _UserListTileState extends State<UserListTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveBreakpoints.isMobile(
      MediaQuery.sizeOf(context).width,
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => _openUserDetail(isMobile),
        child: PreservedTweenAnimationBuilder(
          begin: 0,
          end: 1,
          duration: AnimationConfig.listFadeDuration(widget.index),
          curve: Curves.easeOutCubic,
          builder: (BuildContext context, double value, Widget? child) {
            return Opacity(opacity: value, child: child);
          },
          child: UserListTileContent(
            user: widget.user,
            color: widget.color,
            isHovered: _isHovered,
          ),
        ),
      ),
    );
  }

  Future<void> _openUserDetail(bool isMobile) {
    return openUserDetail(
      context: context,
      user: widget.user,
      color: widget.color,
      isMobile: isMobile,
    );
  }
}
