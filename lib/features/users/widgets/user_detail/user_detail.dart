import 'package:flutter/material.dart';
import 'package:mediahub/core/constants/animation.dart';
import 'package:mediahub/core/constants/responsive.dart';
import 'package:mediahub/data/repositories/user_repository.dart';
import 'package:mediahub/features/users/models/user.dart';
import 'package:mediahub/features/users/models/user_detail_data.dart';
import 'package:mediahub/features/users/widgets/user_detail/shimmer.dart';
import 'package:mediahub/features/users/widgets/user_detail/tabs/activity_tab.dart';
import 'package:mediahub/features/users/widgets/user_detail/tabs/events_tab.dart';
import 'package:mediahub/features/users/widgets/user_detail/tabs/overview_tab.dart';

class UserDetail extends StatefulWidget {
  final User user;
  final Color color;
  final bool enableHero;
  final bool startPulseImmediately;

  const UserDetail({
    super.key,
    required this.user,
    required this.color,
    this.enableHero = true,
    this.startPulseImmediately = false,
  });

  @override
  State<UserDetail> createState() => _UserDetailState();
}

class _UserDetailState extends State<UserDetail>
    with SingleTickerProviderStateMixin {
  late Future<UserDetailData> future;
  final UserRepository repo = UserRepository();

  late final AnimationController controller;
  late final Animation<double> scaleAnim;

  @override
  void initState() {
    super.initState();
    future = repo.getUserDetail(widget.user.id);

    controller = AnimationController(
      vsync: this,
      duration: AnimationConfig.dialogScaleDuration,
      animationBehavior: AnimationBehavior.preserve,
    );

    scaleAnim = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 0.92,
          end: 1.08,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1.08,
          end: 0.98,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 0.98,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
    ]).animate(controller);

    WidgetsBinding.instance.addPostFrameCallback((Duration _) async {
      if (!widget.startPulseImmediately) {
        await Future<void>.delayed(AnimationConfig.dialogStartDelayDuration);
      }
      if (mounted) controller.forward();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ScaleTransition child = ScaleTransition(
      scale: scaleAnim,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            // Calcola dimensioni responsive
            final double screenWidth = MediaQuery.of(context).size.width;
            final double screenHeight = MediaQuery.of(context).size.height;
            final bool isMobile = screenWidth < ResponsiveBreakpoints.mobile;
            final bool isTablet = screenWidth < ResponsiveBreakpoints.tablet;

            late double dialogWidth;
            late double dialogHeight;

            if (isMobile) {
              dialogWidth = screenWidth - 32;
              dialogHeight = screenHeight - 80;
            } else if (isTablet) {
              dialogWidth = screenWidth - 64;
              dialogHeight = screenHeight - 120;
            } else {
              dialogWidth = 1000;
              dialogHeight = 720;
            }

            return SizedBox(
              width: dialogWidth,
              height: dialogHeight,
              child: FutureBuilder<UserDetailData>(
                future: future,
                builder:
                    (
                      BuildContext context,
                      AsyncSnapshot<UserDetailData> snapshot,
                    ) {
                      if (snapshot.hasError) {
                        return _UserDetailError(
                          onRetry: () {
                            setState(() {
                              future = repo.getUserDetail(widget.user.id);
                            });
                          },
                        );
                      }

                      if (!snapshot.hasData) {
                        return const Padding(
                          padding: EdgeInsets.all(24),
                          child: _UserDetailSkeleton(),
                        );
                      }

                      final UserDetailData data = snapshot.data!;
                      final double padding = isMobile ? 16.0 : 24.0;

                      return Padding(
                        padding: EdgeInsets.all(padding),
                        child: Column(
                          children: <Widget>[
                            _Header(
                              user: widget.user,
                              color: widget.color,
                              onClose: () => Navigator.of(context).maybePop(),
                            ),
                            SizedBox(height: isMobile ? 12 : 20),
                            Expanded(
                              child: _UserTabs(data: data, color: widget.color),
                            ),
                          ],
                        ),
                      );
                    },
              ),
            );
          },
        ),
      ),
    );

    if (!widget.enableHero) {
      return child;
    }

    return Hero(tag: 'user-${widget.user.id}', child: child);
  }
}

class _UserDetailSkeleton extends StatelessWidget {
  const _UserDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Header skeleton
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: const Color(0xFFF8FAFC),
            border: Border.all(color: const Color(0xFFE7EAF0)),
          ),
          child: Row(
            children: <Widget>[
              const ShimmerCircle(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const <Widget>[
                    ShimmerBar(width: 180),
                    SizedBox(height: 10),
                    ShimmerBar(width: 220),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        ShimmerBar(width: 84),
                        ShimmerBar(width: 70),
                        ShimmerBar(width: 120),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Tabs + content skeleton
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE7EAF0)),
            ),
            child: Column(
              children: <Widget>[
                // Tab bar skeleton
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE7EAF0)),
                  ),
                  child: Row(
                    children: const <Widget>[
                      Expanded(child: ShimmerBar(width: double.infinity)),
                      SizedBox(width: 8),
                      Expanded(child: ShimmerBar(width: double.infinity)),
                      SizedBox(width: 8),
                      Expanded(child: ShimmerBar(width: double.infinity)),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Content skeleton
                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: 6,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, int index) {
                      if (index % 3 == 0) {
                        return Row(
                          children: const <Widget>[
                            Expanded(
                              child: ShimmerBox(
                                width: double.infinity,
                                height: 96,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: ShimmerBox(
                                width: double.infinity,
                                height: 96,
                              ),
                            ),
                          ],
                        );
                      }

                      return const ShimmerBox(
                        width: double.infinity,
                        height: 96,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _UserDetailError extends StatelessWidget {
  final VoidCallback onRetry;

  const _UserDetailError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE7EAF0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_rounded, size: 42, color: Color(0xFFEF4444)),
            const SizedBox(height: 12),
            const Text(
              'Impossibile caricare i dettagli utente',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Riprova')),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final User user;
  final Color color;
  final VoidCallback onClose;

  const _Header({
    required this.user,
    required this.color,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final Color statusColor = user.isActive
        ? const Color(0xFF22C55E)
        : const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFE7EAF0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Stack(
            alignment: Alignment.bottomRight,
            children: <Widget>[
              CircleAvatar(
                radius: 42,
                backgroundColor: color.withValues(alpha: 0.14),
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
                duration: AnimationConfig.statusPulseDuration,
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      blurRadius: user.isActive ? 10 : 4,
                      color: statusColor.withValues(alpha: 0.28),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${user.name} ${user.lastName}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(user.email, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    _Badge(label: user.role, color: color),
                    _Badge(
                      label: user.isActive ? 'Attivo' : 'Inattivo',
                      color: statusColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            tooltip: 'Chiudi',
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _UserTabs extends StatelessWidget {
  final UserDetailData data;
  final Color color;

  const _UserTabs({required this.data, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE7EAF0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: DefaultTabController(
          length: 3,
          child: Column(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE7EAF0)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: TabBar(
                    dividerColor: Colors.transparent,
                    splashFactory: NoSplash.splashFactory,
                    overlayColor: WidgetStateProperty.all(Colors.transparent),

                    indicator: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),

                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: color,
                    unselectedLabelColor: Colors.grey,
                    tabs: const <Widget>[
                      Tab(text: "Panoramica"),
                      Tab(text: "Attivita"),
                      Tab(text: "Eventi"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: TabBarView(
                  children: <Widget>[
                    OverviewTab(data: data),
                    ActivityTab(data: data),
                    EventsTab(data: data),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
