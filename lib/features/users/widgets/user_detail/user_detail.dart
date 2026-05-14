import 'package:flutter/material.dart';
import 'package:mediahub/core/constants/color.dart';
import 'package:mediahub/data/repositories/user_repository.dart';
import 'package:mediahub/features/users/models/user.dart';
import 'package:mediahub/features/users/models/user_detail_data.dart';
import 'package:mediahub/features/users/widgets/user_detail/shimmer.dart';
import 'package:mediahub/features/users/widgets/user_detail/tabs/activity_tab.dart';
import 'package:mediahub/features/users/widgets/user_detail/tabs/content_tab.dart';
import 'package:mediahub/features/users/widgets/user_detail/tabs/events_tab.dart';
import 'package:mediahub/features/users/widgets/user_detail/tabs/overview_tab.dart';

class UserDetail extends StatefulWidget {
  final User user;
  final Color color;

  const UserDetail({super.key, required this.user, required this.color});

  @override
  State<UserDetail> createState() => _UserDetailState();
}

class _UserDetailState extends State<UserDetail>
    with SingleTickerProviderStateMixin {
  late Future<UserDetailData> future;
  final repo = UserRepository();
  late final AnimationController controller;
  late final Animation<double> scaleAnim;

  @override
  void initState() {
    super.initState();

    future = repo.getUserDetail(widget.user.id);

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.9,
          end: 1.1,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.1,
          end: 0.95,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.95,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
    ]).animate(controller);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        controller.forward();
      }
    });
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

        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,

          child: SizedBox(
            width: 1000,
            height: 700,
            child: Padding(
              padding: const EdgeInsets.all(24),

              child: Column(
                children: [
                  _Header(user: widget.user, color: widget.color),

                  const SizedBox(height: 12),

                  Expanded(
                    child: _UserTabsLoader(
                      userId: widget.user.id,
                      user: widget.user,
                    ),
                  ),
                ],
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
        Stack(
          alignment: Alignment.bottomRight,
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

            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: user.isActive ? Colors.green : Colors.red,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    blurRadius: user.isActive ? 10 : 3,
                    color: (user.isActive ? Colors.green : Colors.red)
                        .withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Text(
          '${user.name} ${user.lastName}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        Text(user.role, style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class _UserTabsLoader extends StatefulWidget {
  final int userId;
  final User user;

  const _UserTabsLoader({required this.userId, required this.user});

  @override
  State<_UserTabsLoader> createState() => _UserTabsLoaderState();
}

class _UserTabsLoaderState extends State<_UserTabsLoader> {
  final repo = UserRepository();

  late Future<UserDetailData> future;

  @override
  void initState() {
    super.initState();
    future = repo.getUserDetail(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserDetailData>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _UserDetailSkeleton();
        }

        final data = snapshot.data!;

        return _UserTabs(data: data);
      },
    );
  }
}

class _UserDetailSkeleton extends StatelessWidget {
  const _UserDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),

        // tabs skeleton
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(4, (_) => const ShimmerBar(width: 70)),
        ),

        const SizedBox(height: 20),

        // content skeleton
        Expanded(
          child: ListView.builder(
            itemCount: 7,
            itemBuilder: (_, __) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 16,
                ),
                child: Row(
                  children: const [
                    Expanded(
                      child: ShimmerBox(width: double.infinity, height: 85),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ShimmerBox(width: double.infinity, height: 85),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _UserTabs extends StatelessWidget {
  final UserDetailData data;

  const _UserTabs({required this.data});

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
                OverviewTab(data: data),
                ActivityTab(data: data),
                EventsTab(data: data),
                ContentTab(data: data),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
