import 'package:flutter/material.dart';
import 'package:mediahub/core/constants/animation.dart';
import 'package:mediahub/core/constants/color.dart';
import 'package:mediahub/features/dashboard/models/dashboard_data.dart';

/// Responsive grid of the four summary metrics shown below the alerts.
class DashboardMetricsGrid extends StatelessWidget {
  final DashboardMetrics metrics;

  const DashboardMetricsGrid({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final List<_MetricData> cards = <_MetricData>[
      _MetricData(
        'Eventi',
        '${metrics.totalEvents}',
        '${metrics.upcomingThisWeek} nei prossimi 7g',
        Icons.event_rounded,
        primaryColor,
      ),
      _MetricData(
        'Live ora',
        '${metrics.liveEvents}',
        '${metrics.eventsWithoutContents} senza contenuti',
        Icons.bolt_rounded,
        successColor,
      ),
      _MetricData(
        'Contenuti',
        '${metrics.totalContents}',
        '${metrics.publishedContents} pubblicati',
        Icons.article_rounded,
        warningColor,
      ),
      _MetricData(
        'Media',
        '${metrics.totalMediaAssets}',
        'asset collegati agli eventi',
        Icons.perm_media_rounded,
        accentPinkColor,
      ),
    ];

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columns = constraints.maxWidth >= 1200
            ? 4
            : constraints.maxWidth >= 700
            ? 2
            : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 112,
          ),
          itemBuilder: (BuildContext context, int index) =>
              _MetricCard(data: cards[index]),
        );
      },
    );
  }
}

class _MetricCard extends StatefulWidget {
  final _MetricData data;

  const _MetricCard({required this.data});

  @override
  State<_MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<_MetricCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final _MetricData data = widget.data;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: AnimationConfig.hoverDuration,
        transform: _isHovered
            ? (Matrix4.identity()..translateByDouble(0, -4, 0, 1))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: DashboardColors.border),
          boxShadow: _isHovered
              ? const <BoxShadow>[
                  BoxShadow(
                    blurRadius: 30,
                    offset: Offset(0, 12),
                    color: DashboardColors.mediumShadow,
                  ),
                ]
              : const <BoxShadow>[
                  BoxShadow(
                    blurRadius: 18,
                    offset: Offset(0, 8),
                    color: DashboardColors.softShadow,
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: data.accent.withValues(alpha: 0.12),
                ),
                child: Icon(data.icon, color: data.accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      data.title,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: <Widget>[
                        Text(
                          data.value,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            data.detail,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: data.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _MetricData {
  final String title;
  final String value;
  final String detail;
  final IconData icon;
  final Color accent;

  const _MetricData(
    this.title,
    this.value,
    this.detail,
    this.icon,
    this.accent,
  );
}
