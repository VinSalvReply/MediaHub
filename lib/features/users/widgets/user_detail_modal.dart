import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mediahub/features/users/models/user.dart';

class UserDetailModal extends StatefulWidget {
  final User user;
  final Color color;

  const UserDetailModal({super.key, required this.user, required this.color});

  @override
  State<UserDetailModal> createState() => _UserDetailModalState();
}

class _UserDetailModalState extends State<UserDetailModal>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> anim;
  late Animation<double> scaleAnim;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    anim = CurvedAnimation(
      parent: controller,
      curve: const Interval(0, 0.85, curve: Curves.easeOut),
    );

    scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.5,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.5,
          end: 0.8,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.8,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
    ]).animate(anim);

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'user-${widget.user.id}',
      child: ScaleTransition(
        scale: scaleAnim,
        child: FadeTransition(
          opacity: anim,
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              width: 900,
              height: 600,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _Header(user: widget.user, color: widget.color),
                    const SizedBox(height: 20),
                    Expanded(child: _UserTabs(user: widget.user)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final User user;
  final Color color;

  const _Header({required this.user, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 42,
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

        const SizedBox(height: 10),

        Text(
          '${user.name} ${user.lastName}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        Text(user.email, style: TextStyle(color: Colors.grey)),

        const SizedBox(height: 8),

        Chip(label: Text(user.role)),
      ],
    );
  }
}

class _UserTabs extends StatelessWidget {
  final User user;

  const _UserTabs({required this.user});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: "Overview"),
              Tab(text: "Activity"),
              Tab(text: "Events"),
              Tab(text: "Content"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // _OverviewTab(user: user),
                // _ActivityTab(user: user),
                // _EventsTab(user: user),
                // _ContentTab(user: user),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
