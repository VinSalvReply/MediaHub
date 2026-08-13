import 'package:flutter/material.dart';
import 'package:mediahub/core/constants/animation.dart';
import 'package:mediahub/core/constants/color.dart';
import 'package:mediahub/core/constants/responsive.dart';
import 'package:mediahub/core/utils/date.dart';
import 'package:mediahub/core/utils/preserved_tween_animation_builder.dart';
import 'package:mediahub/features/users/models/user.dart';
import 'package:mediahub/features/users/widgets/user_detail/user_detail.dart';

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
  bool hovered = false;
  bool isTransitioning = false;

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final color = widget.color;
    final isMobile = ResponsiveBreakpoints.isMobile(
      MediaQuery.sizeOf(context).width,
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: GestureDetector(
        onTap: () async {
          setState(() => isTransitioning = true);
          final transitionDuration = isMobile
              ? Duration.zero
              : AnimationConfig.heroForwardDuration;
          final reverseTransitionDuration = isMobile
              ? Duration.zero
              : AnimationConfig.heroReverseDuration;

          await Navigator.of(context).push(
            PageRouteBuilder(
              transitionDuration: transitionDuration,
              reverseTransitionDuration: reverseTransitionDuration,
              opaque: false,
              pageBuilder: (_, _, _) {
                return Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Stack(
                    children: [
                      ModalBarrier(
                        dismissible: true,
                        color: Colors.black.withValues(alpha: 0.5),
                      ),
                      Center(
                        child: UserDetail(
                          user: user,
                          color: color,
                          enableHero: !isMobile,
                          startPulseImmediately: isMobile,
                        ),
                      ),
                    ],
                  ),
                );
              },
              transitionsBuilder: (_, animation, _, child) {
                return child;
              },
            ),
          );

          setState(() => isTransitioning = false);
        },
        child: PreservedTweenAnimationBuilder(
          begin: 0,
          end: 1,
          duration: AnimationConfig.gridEntryDuration(widget.index),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            final slide = (1 - value);
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
            scale: hovered && !isTransitioning ? 1.02 : 1.0,
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: AnimationConfig.hoverDuration,
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    blurRadius: hovered ? 28 : 18,
                    offset: Offset(0, hovered ? 14 : 8),
                    color: Colors.black.withValues(
                      alpha: hovered ? 0.14 : 0.08,
                    ),
                  ),
                ],
              ),
              child: (isMobile
                  ? Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _CardContent(user: user, color: color),
                    )
                  : Hero(
                      tag: 'user-${user.id}',
                      child: Card(
                        elevation: 0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _CardContent(user: user, color: color),
                      ),
                    )),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  final User user;
  final Color color;

  const _CardContent({required this.user, required this.color});

  @override
  Widget build(BuildContext context) {
    final statusColor = user.isActive
        ? const Color(0xFF22C55E)
        : const Color(0xFFEF4444);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isMobileSize = width < 340;

        // Valori responsivi
        final headerHeight = isMobileSize ? 95.0 : 110.0;
        final avatarRadius = isMobileSize ? 38.0 : 43.0;
        final avatarSize = isMobileSize ? 96.0 : 106.0;
        final avatarFontSize = isMobileSize ? 24.0 : 28.0;
        final nameSize = isMobileSize ? 16.0 : 18.0;
        final horizontalPadding = isMobileSize ? 20.0 : 28.0;
        final headerTranslate = isMobileSize ? -48.0 : -55.0;

        return Column(
          children: [
            Container(
              height: headerHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.95),
                    color.withValues(alpha: 0.65),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(26),
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(0, headerTranslate),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: avatarSize,
                        height: avatarSize,
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        child: CircleAvatar(
                          radius: (avatarSize / 2),
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: avatarRadius,
                            backgroundColor: color.withValues(alpha: 0.15),
                            child: Text(
                              '${user.name[0]}${user.lastName[0]}',
                              style: TextStyle(
                                color: color,
                                fontSize: avatarFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: AnimationConfig.statusPulseDuration,
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusColor,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: user.isActive ? 10 : 4,
                              color: statusColor.withValues(alpha: 0.30),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '${user.name} ${user.lastName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: nameSize,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      user.role,
                      style: TextStyle(
                        fontSize: isMobileSize ? 11 : 12,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoRow(
                          icon: Icons.email_rounded,
                          text: user.email,
                          compact: isMobileSize,
                        ),
                        const SizedBox(height: 6),
                        _InfoRow(
                          icon: Icons.calendar_today_rounded,
                          text:
                              'Creato il ${formatDate(user.createdAt, format: "dd-MM-yyyy")}',
                          compact: isMobileSize,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool compact;

  const _InfoRow({
    required this.icon,
    required this.text,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: compact ? 13 : 14, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: compact ? 12 : 13, color: greyLight),
          ),
        ),
      ],
    );
  }
}
