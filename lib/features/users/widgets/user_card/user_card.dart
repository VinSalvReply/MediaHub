import 'package:flutter/material.dart';
import 'package:mediahub/core/constants/animation.dart';
import 'package:mediahub/core/utils/preserved_tween_animation_builder.dart';
import 'package:mediahub/features/users/models/user.dart';
import 'package:mediahub/features/users/widgets/user_card/user_card_content.dart';
import 'package:mediahub/features/users/widgets/user_detail/user_detail_route.dart';

class UserCard extends StatefulWidget {
  final User user;
  final Color color;
  final int index;

  const UserCard({
    super.key,
    required this.user,
    required this.color,
    required this.index,
  });

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  bool _isHovered = false;
  bool _isTransitioning = false;

  @override
  Widget build(BuildContext context) {
    final User user = widget.user;
    final Color color = widget.color;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => _openUserDetail(user: user, color: color),
        child: PreservedTweenAnimationBuilder(
          begin: 0,
          end: 1,
          duration: AnimationConfig.gridEntryDuration(widget.index),
          curve: Curves.easeOutCubic,
          builder: (BuildContext context, double value, Widget? child) {
            final double slide = (1 - value);
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, slide * 50),
                child: Transform.scale(
                  scale: 0.95 + (0.05 * value),
                  child: child,
                ),
              ),
            );
          },
          child: AnimatedScale(
            duration: AnimationConfig.hoverDuration,
            scale: _isHovered && !_isTransitioning ? 1.02 : 1.0,
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: AnimationConfig.hoverDuration,
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    blurRadius: _isHovered ? 28 : 18,
                    offset: Offset(0, _isHovered ? 14 : 8),
                    color: Colors.black.withValues(
                      alpha: _isHovered ? 0.14 : 0.08,
                    ),
                  ),
                ],
              ),
              child: Hero(
                tag: 'user-${user.id}',
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: UserCardContent(user: user, color: color),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openUserDetail({
    required User user,
    required Color color,
  }) async {
    setState(() => _isTransitioning = true);

    try {
      await openUserDetail(
        context: context,
        user: user,
        color: color,
        enableHero: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isTransitioning = false);
      }
    }
  }
}
