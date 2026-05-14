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
    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: GestureDetector(
        onTap: () async {
          {
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
                          child: UserDetail(
                            user: widget.user,
                            color: widget.color,
                          ),
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

                  return Stack(
                    children: [
                      AnimatedBuilder(
                        animation: curved,
                        builder: (context, _) {
                          return Container(
                            color: Colors.black.withValues(
                              alpha: 0.5 * curved.value,
                            ),
                          );
                        },
                      ),

                      child,
                    ],
                  );
                },
              ),
            );

            setState(() => isTransitioning = false);
          }
        },

        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          scale: hovered && !isTransitioning ? 1.02 : 1.0,
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            transform: Matrix4.identity()
              ..scale(hovered ? 1.02 : 1.0, hovered ? 1.01 : 1.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: hovered
                  ? [const BoxShadow(blurRadius: 25, color: Colors.black12)]
                  : [],
            ),
            child: Hero(
              tag: 'user-${widget.user.id}',
              flightShuttleBuilder: (context, animation, direction, from, to) {
                final curved = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCubic,
                );

                return AnimatedBuilder(
                  animation: curved,
                  builder: (context, _) {
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..setEntry(3, 2, 0.001),
                      child: Material(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.transparent,
                        child: to.widget,
                      ),
                    );
                  },
                );
              },
              child: Card(
                elevation: hovered ? 10 : 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(color: defaultColorLight!, width: 4),
                ),
                clipBehavior: Clip.antiAlias,
                child: _CardContent(user: widget.user, color: widget.color),
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
    return Column(
      children: [
        Container(
          height: 110,
          width: double.infinity,
          decoration: BoxDecoration(
            color: defaultColorLight,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(24),
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -55),
          child: Column(
            children: [
              _AvatarWithStatus(
                id: user.id,
                initials: '${user.name[0]}${user.lastName[0]}',
                isActive: user.isActive,
                color: color,
              ),
              const SizedBox(height: 10),
              Text(
                '${user.name} ${user.lastName}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(user.role, style: TextStyle(fontSize: 13, color: greyLight)),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(icon: Icons.email, text: user.email),
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.calendar_today,
                      text:
                          'Creato il ${formatDate(user.createdAt, format: "dd-mm-yyyy")}',
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

class _AvatarWithStatus extends StatelessWidget {
  final int id;
  final String initials;
  final bool isActive;
  final Color color;

  const _AvatarWithStatus({
    required this.id,
    required this.initials,
    required this.isActive,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 115,
          height: 115,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: defaultColorLight!, width: 5),
          ),

          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,

            child: CircleAvatar(
              radius: 42,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Text(
                initials,
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
          duration: const Duration(milliseconds: 300),
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.green : Colors.red,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                blurRadius: isActive ? 10 : 3,
                color: (isActive ? Colors.green : Colors.red).withValues(
                  alpha: 0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
