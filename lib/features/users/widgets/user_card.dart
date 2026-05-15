import 'package:flutter/material.dart';
import 'package:mediahub/core/constants/color.dart';
import 'package:mediahub/core/utils/date.dart';
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

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: GestureDetector(
        onTap: () async {
          setState(() => isTransitioning = true);

          await Navigator.of(context).push(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 500),
              reverseTransitionDuration: const Duration(milliseconds: 400),
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
                        child: UserDetail(user: user, color: color),
                      ),
                    ],
                  ),
                );
              },
              transitionsBuilder: (_, animation, _, child) {
                final curved = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCubic,
                );

                return FadeTransition(opacity: curved, child: child);
              },
            ),
          );

          setState(() => isTransitioning = false);
        },
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 400 + (widget.index * 60)),
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
            duration: const Duration(milliseconds: 180),
            scale: hovered && !isTransitioning ? 1.02 : 1.0,
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
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
              child: Hero(
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
              ),
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

    return Column(
      children: [
        Container(
          height: 110,
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
          offset: const Offset(0, -55),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 106,
                    height: 106,
                    decoration: BoxDecoration(shape: BoxShape.circle),
                    child: CircleAvatar(
                      radius: 43,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 43,
                        backgroundColor: color.withValues(alpha: 0.15),
                        child: Text(
                          '${user.name[0]}${user.lastName[0]}',
                          style: TextStyle(
                            color: color,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
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
              Text(
                '${user.name} ${user.lastName}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
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
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(icon: Icons.email_rounded, text: user.email),
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.calendar_today_rounded,
                      text:
                          'Creato il ${formatDate(user.createdAt, format: "dd-MM-yyyy")}',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: greyLight),
          ),
        ),
      ],
    );
  }
}
