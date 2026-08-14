import 'package:flutter/material.dart';
import 'package:mediahub/core/constants/color.dart';
import 'package:mediahub/core/constants/responsive.dart';
import 'package:mediahub/features/users/widgets/user_detail/shimmer.dart';

/// Loading placeholder that mirrors the dashboard's responsive layout.
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _SkeletonBar(width: 260, height: 34),
          const SizedBox(height: 10),
          const _SkeletonBar(width: 320, height: 18),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List<Widget>.generate(
              2,
              (int _) => const _SkeletonPill(width: 220, height: 44),
            ),
          ),
          const SizedBox(height: 24),
          _MetricsSkeletonGrid(),
          const SizedBox(height: 24),
          _SectionsSkeleton(),
          const SizedBox(height: 20),
          const _PanelSkeleton(lines: 5),
          const SizedBox(height: 20),
          const _PanelSkeleton(lines: 3),
        ],
      ),
    );
  }
}

/// Mirrors the metric grid while the dashboard data is loading.
class _MetricsSkeletonGrid extends StatelessWidget {
  const _MetricsSkeletonGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columnCount = constraints.maxWidth >= 1200
            ? 4
            : constraints.maxWidth >= 700
            ? 2
            : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 112,
          ),
          itemBuilder: (_, _) => const _MetricSkeleton(),
        );
      },
    );
  }
}

/// Mirrors the wide/tall section arrangement of the loaded dashboard.
class _SectionsSkeleton extends StatelessWidget {
  const _SectionsSkeleton();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth >= ResponsiveBreakpoints.desktop) {
          return const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: _PanelSkeleton(lines: 4)),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: <Widget>[
                    _PanelSkeleton(lines: 4),
                    SizedBox(height: 20),
                    _PanelSkeleton(lines: 4),
                  ],
                ),
              ),
            ],
          );
        }

        return const Column(
          children: <Widget>[
            _PanelSkeleton(lines: 4),
            SizedBox(height: 20),
            _PanelSkeleton(lines: 4),
            SizedBox(height: 20),
            _PanelSkeleton(lines: 4),
          ],
        );
      },
    );
  }
}

class _MetricSkeleton extends StatelessWidget {
  const _MetricSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: DashboardColors.border),
      ),
      child: const Row(
        children: <Widget>[
          _SkeletonPill(width: 52, height: 52),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _SkeletonBar(width: 70, height: 12),
                SizedBox(height: 8),
                _SkeletonBar(width: 100, height: 22),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelSkeleton extends StatelessWidget {
  final int lines;

  const _PanelSkeleton({required this.lines});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: DashboardColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _SkeletonBar(width: 160, height: 18),
          const SizedBox(height: 6),
          const _SkeletonBar(width: 220, height: 12),
          const SizedBox(height: 16),
          ...List<Widget>.generate(
            lines,
            (int index) => Padding(
              padding: EdgeInsets.only(bottom: index == lines - 1 ? 0 : 12),
              child: const _SkeletonBar(width: double.infinity, height: 58),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonBar extends StatelessWidget {
  final double width;
  final double height;

  const _SkeletonBar({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: DashboardColors.skeleton,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _SkeletonPill extends StatelessWidget {
  final double width;
  final double height;

  const _SkeletonPill({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: DashboardColors.skeleton,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}
