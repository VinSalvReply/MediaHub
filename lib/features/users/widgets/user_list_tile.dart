import 'package:flutter/material.dart';
import 'package:mediahub/core/constants/animation.dart';
import 'package:mediahub/core/constants/responsive.dart';
import 'package:mediahub/features/users/models/user.dart';
import 'package:mediahub/features/users/widgets/user_detail/user_detail.dart';

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

class _UserListTileState extends State<UserListTile>
    with SingleTickerProviderStateMixin {
  bool hovered = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimationConfig.listFadeDuration(widget.index),
      vsync: this,
      animationBehavior: AnimationBehavior.preserve,
    );
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User user = widget.user;
    final Color color = widget.color;
    final bool isMobile = ResponsiveBreakpoints.isMobile(
      MediaQuery.sizeOf(context).width,
    );
    final Color statusColor = user.isActive
        ? const Color(0xFF22C55E)
        : const Color(0xFFEF4444);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => hovered = true),
        onExit: (_) => setState(() => hovered = false),
        child: GestureDetector(
          onTap: () async {
            final Duration transitionDuration = isMobile
                ? Duration.zero
                : AnimationConfig.heroForwardDuration;
            final Duration reverseTransitionDuration = isMobile
                ? Duration.zero
                : AnimationConfig.heroReverseDuration;

            await Navigator.of(context).push(
              PageRouteBuilder<void>(
                transitionDuration: transitionDuration,
                reverseTransitionDuration: reverseTransitionDuration,
                opaque: false,
                pageBuilder: (
                  BuildContext _,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                ) {
                  return Scaffold(
                    backgroundColor: Colors.transparent,
                    body: Stack(
                      children: <Widget>[
                        ModalBarrier(
                          dismissible: true,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                        Center(
                          child: UserDetail(
                            user: user,
                            color: color,
                            startPulseImmediately: isMobile,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                transitionsBuilder: (_, Animation<double> animation, _, Widget child) {
                  return child;
                },
              ),
            );
          },
          child: AnimatedContainer(
            duration: AnimationConfig.hoverDuration,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              border: Border.all(
                color: hovered
                    ? color.withValues(alpha: 0.3)
                    : Colors.grey.shade200,
                width: hovered ? 2 : 1,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  blurRadius: hovered ? 12 : 4,
                  offset: Offset(0, hovered ? 4 : 2),
                  color: Colors.black.withValues(alpha: hovered ? 0.08 : 0.04),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                // Avatar
                Stack(
                  alignment: Alignment.bottomRight,
                  children: <Widget>[
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: <Color>[
                            color.withValues(alpha: 0.8),
                            color.withValues(alpha: 0.5),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${user.name[0]}${user.lastName[0]}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Status indicator
                    AnimatedContainer(
                      duration: AnimationConfig.statusPulseDuration,
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusColor,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            blurRadius: user.isActive ? 6 : 2,
                            color: statusColor.withValues(alpha: 0.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              '${user.name} ${user.lastName}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          user.role,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow icon
                AnimatedRotation(
                  turns: hovered ? 0.1 : 0,
                  duration: AnimationConfig.hoverDuration,
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: color.withValues(alpha: hovered ? 1 : 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
