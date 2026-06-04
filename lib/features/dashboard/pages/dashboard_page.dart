import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mediahub/core/utils/date.dart';
import 'package:mediahub/data/repositories/dashboard_repository.dart';
import 'package:mediahub/features/dashboard/models/dashboard_data.dart';
import 'package:mediahub/features/users/widgets/user_detail/shimmer.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late Future<DashboardData> _future;

  final DashboardRepository _repository = DashboardRepository();

  @override
  void initState() {
    super.initState();
    _future = _repository.getDashboard();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _future = _repository.getDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: FutureBuilder<DashboardData>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _DashboardError(
                  message: snapshot.error.toString(),
                  onRetry: _reload,
                );
              }

              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: _DashboardSkeleton(),
                );
              }

              return _DashboardView(
                data: snapshot.data!,
                onRefreshTap: _reload,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DashboardView extends StatelessWidget {
  final DashboardData data;
  final VoidCallback onRefreshTap;

  const _DashboardView({required this.data, required this.onRefreshTap});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1200;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopBar(
                  title: 'Dashboard MediaHub',
                  subtitle:
                      'Controllo operativo di eventi, contenuti e copertura media',
                  onSearchTap: () {},
                  onRefreshTap: onRefreshTap,
                ),
                const SizedBox(height: 24),
                _AlertStrip(alerts: data.alerts),
                const SizedBox(height: 24),
                _MetricsGrid(metrics: data.metrics),
                const SizedBox(height: 24),
                if (wide)
                  SizedBox(
                    height: 876,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 3,

                          child: _SectionCard(
                            title: 'Attività recenti',
                            subtitle:
                                'Eventi e contenuti che stanno muovendo la pipeline',
                            expandChild: true,
                            child: _ActivityFeed(items: data.activities),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 2,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                _SectionCard(
                                  title: 'Copertura operativa',
                                  subtitle:
                                      'Indicatori rapidi sulla qualità del piano editoriale',
                                  child: _InsightsPanel(items: data.insights),
                                ),

                                const SizedBox(height: 20),
                                _SectionCard(
                                  title: 'Eventi da attenzionare',
                                  subtitle:
                                      'Priorità operative tra contenuti mancanti, draft e media',
                                  child: _FocusEventsPanel(
                                    events: data.focusEvents,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  _SectionCard(
                    title: 'Attività recenti',
                    subtitle:
                        'Eventi e contenuti che stanno muovendo la pipeline',
                    child: _ActivityFeed(items: data.activities),
                  ),
                  const SizedBox(height: 20),
                  _SectionCard(
                    title: 'Copertura operativa',
                    subtitle:
                        'Indicatori rapidi sulla qualità del piano editoriale',
                    child: _InsightsPanel(items: data.insights),
                  ),
                  const SizedBox(height: 20),
                  _SectionCard(
                    title: 'Eventi da attenzionare',
                    subtitle:
                        'Priorità operative tra contenuti mancanti, draft e media',
                    child: _FocusEventsPanel(events: data.focusEvents),
                  ),
                ],
                const SizedBox(height: 20),
                _SectionCard(
                  title: 'Trend operativo',
                  subtitle:
                      'Andamento di utenti attivi e contenuti creati nel tempo',
                  child: _TrendPanel(trend: data.trend),
                ),
                const SizedBox(height: 20),
                _SectionCard(
                  title: 'Azioni rapide',
                  subtitle:
                      'Le operazioni più frequenti per tenere vivo il calendario',
                  child: const _QuickActionsGrid(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onSearchTap;
  final VoidCallback onRefreshTap;

  const _TopBar({
    required this.title,
    required this.subtitle,
    required this.onSearchTap,
    required this.onRefreshTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        _IconActionButton(icon: Icons.search_rounded, onTap: onSearchTap),
        const SizedBox(width: 10),
        _IconActionButton(icon: Icons.refresh_rounded, onTap: onRefreshTap),
      ],
    );
  }
}

class _IconActionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconActionButton({required this.icon, required this.onTap});

  @override
  State<_IconActionButton> createState() => _IconActionButtonState();
}

class _IconActionButtonState extends State<_IconActionButton> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: hovered ? Colors.white : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE7EAF0)),
          boxShadow: hovered
              ? const [
                  BoxShadow(
                    blurRadius: 20,
                    offset: Offset(0, 8),
                    color: Color(0x12000000),
                  ),
                ]
              : const [],
        ),
        child: IconButton(
          onPressed: widget.onTap,
          icon: Icon(widget.icon, size: 20),
        ),
      ),
    );
  }
}

class _AlertStrip extends StatelessWidget {
  final List<DashboardAlert> alerts;

  const _AlertStrip({required this.alerts});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: alerts.map((alert) => _AlertChip(alert: alert)).toList(),
    );
  }
}

class _AlertChip extends StatelessWidget {
  final DashboardAlert alert;

  const _AlertChip({required this.alert});

  Color _colorFor(String type) {
    switch (type) {
      case 'warning':
        return const Color(0xFFF59E0B);
      case 'info':
        return const Color(0xFF4F46E5);
      case 'error':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'warning':
        return Icons.warning_rounded;
      case 'info':
        return Icons.info_rounded;
      case 'error':
        return Icons.error_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(alert.type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_iconFor(alert.type), size: 18, color: color),
          const SizedBox(width: 10),
          Text(
            alert.message,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  final DashboardMetrics metrics;

  const _MetricsGrid({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final cards = <_MetricCardData>[
      _MetricCardData(
        title: 'Eventi',
        value: metrics.totalEvents.toString(),
        detail: '${metrics.upcomingThisWeek} nei prossimi 7g',
        icon: Icons.event_rounded,
        accent: const Color(0xFF4F46E5),
      ),
      _MetricCardData(
        title: 'Live ora',
        value: metrics.liveEvents.toString(),
        detail: '${metrics.eventsWithoutContents} senza contenuti',
        icon: Icons.bolt_rounded,
        accent: const Color(0xFF14B8A6),
      ),
      _MetricCardData(
        title: 'Contenuti',
        value: metrics.totalContents.toString(),
        detail: '${metrics.publishedContents} pubblicati',
        icon: Icons.article_rounded,
        accent: const Color(0xFFF59E0B),
      ),
      _MetricCardData(
        title: 'Media',
        value: metrics.totalMediaAssets.toString(),
        detail: 'asset collegati agli eventi',
        icon: Icons.perm_media_rounded,
        accent: const Color(0xFFEC4899),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 1200
            ? 4
            : constraints.maxWidth >= 900
            ? 2
            : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.8,
          ),
          itemBuilder: (context, index) {
            return _MetricCard(metric: cards[index]);
          },
        );
      },
    );
  }
}

class _MetricCard extends StatefulWidget {
  final _MetricCardData metric;

  const _MetricCard({required this.metric});

  @override
  State<_MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<_MetricCard> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final metric = widget.metric;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: hovered
            ? (Matrix4.identity()..translateByDouble(0.0, -4.0, 0.0, 1.0))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE7EAF0)),
          boxShadow: hovered
              ? const [
                  BoxShadow(
                    blurRadius: 30,
                    offset: Offset(0, 12),
                    color: Color(0x12000000),
                  ),
                ]
              : const [
                  BoxShadow(
                    blurRadius: 18,
                    offset: Offset(0, 8),
                    color: Color(0x08000000),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: metric.accent.withValues(alpha: 0.12),
                ),
                child: Icon(metric.icon, color: metric.accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      metric.title,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          metric.value,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          metric.detail,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: widget.metric.accent,
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

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final bool expandChild;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
    this.expandChild = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE7EAF0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
            ),
            const SizedBox(height: 16),
            if (expandChild) Expanded(child: child) else child,
          ],
        ),
      ),
    );
  }
}

class _ActivityFeed extends StatelessWidget {
  final List<DashboardActivity> items;

  const _ActivityFeed({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.asMap().entries.map((entry) {
        final isLast = entry.key == items.length - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
          child: _ActivityRow(item: entry.value),
        );
      }).toList(),
    );
  }
}

class _ActivityRow extends StatefulWidget {
  final DashboardActivity item;

  const _ActivityRow({required this.item});

  @override
  State<_ActivityRow> createState() => _ActivityRowState();
}

class _ActivityRowState extends State<_ActivityRow> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final color = _activityColor(item.type);

    return RepaintBoundary(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => hovered = true),
        onExit: (_) => setState(() => hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: hovered ? const Color(0xFFF8FAFC) : const Color(0xFFFDFDFE),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE7EAF0)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: color.withValues(alpha: 0.12),
                ),
                child: Icon(_activityIcon(item.type), color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                _formatShortDateTime(item.date),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsightsPanel extends StatelessWidget {
  final List<DashboardInsight> items;

  const _InsightsPanel({required this.items});

  @override
  Widget build(BuildContext context) {
    final palette = <Color>[
      const Color(0xFF4F46E5),
      const Color(0xFF14B8A6),
      const Color(0xFFEC4899),
      const Color(0xFF22C55E),
    ];

    return Column(
      children: items
          .asMap()
          .entries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _InsightBar(
                item: entry.value,
                color: palette[entry.key % palette.length],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _InsightBar extends StatelessWidget {
  final DashboardInsight item;
  final Color color;

  const _InsightBar({required this.item, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFE7EAF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                '${(item.value * 100).round()}%',
                style: TextStyle(fontWeight: FontWeight.w800, color: color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: item.value,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusEventsPanel extends StatelessWidget {
  final List<DashboardFocusEvent> events;

  const _FocusEventsPanel({required this.events});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: events
          .asMap()
          .entries
          .map(
            (entry) => Padding(
              padding: EdgeInsets.only(
                bottom: entry.key == events.length - 1 ? 0 : 12,
              ),
              child: _FocusEventTile(event: entry.value),
            ),
          )
          .toList(),
    );
  }
}

class _FocusEventTile extends StatelessWidget {
  final DashboardFocusEvent event;

  const _FocusEventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final progress = event.contentCount == 0
        ? 0.0
        : event.publishedCount / event.contentCount;
    final statusColor = _focusStatusColor(event.status, event.needsAttention);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFE7EAF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _focusStatusLabel(event.status, event.needsAttention),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  event.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                formatDate(event.date, format: 'dd/MM HH:mm'),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${event.contentCount} contenuti, ${event.publishedCount} pubblicati, ${event.mediaCount} media collegati',
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: progress,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendPanel extends StatefulWidget {
  final List<DashboardTrendPoint> trend;

  const _TrendPanel({required this.trend});

  @override
  State<_TrendPanel> createState() => _TrendPanelState();
}

class _TrendPanelState extends State<_TrendPanel> {
  int? hoveredIndex;
  final GlobalKey _stackKey = GlobalKey();
  final Map<int, GlobalKey> _groupKeys = <int, GlobalKey>{};

  GlobalKey _groupKeyForIndex(int index) {
    return _groupKeys.putIfAbsent(index, () => GlobalKey());
  }

  double? _tooltipLeft(double availableWidth) {
    final index = hoveredIndex;
    if (index == null) return null;

    final groupContext = _groupKeyForIndex(index).currentContext;
    final stackContext = _stackKey.currentContext;
    if (groupContext == null || stackContext == null) return null;

    final groupBox = groupContext.findRenderObject() as RenderBox?;
    final stackBox = stackContext.findRenderObject() as RenderBox?;
    if (groupBox == null || stackBox == null) return null;

    const tooltipWidth = _TrendInfoCard.cardWidth;
    final centerInStack = groupBox.localToGlobal(
      groupBox.size.center(Offset.zero),
      ancestor: stackBox,
    );

    final rawLeft = centerInStack.dx - (tooltipWidth / 2);
    final maxLeft = math.max(0.0, availableWidth - tooltipWidth);
    return rawLeft.clamp(0.0, maxLeft);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.trend.isEmpty) return const SizedBox.shrink();

    final maxValue = widget.trend
        .map((e) => math.max(e.activeUsers, e.contentCreated))
        .reduce(math.max)
        .toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            _TrendLegend(color: Color(0xFF4F46E5), label: 'Utenti attivi'),
            SizedBox(width: 16),
            _TrendLegend(color: Color(0xFFEC4899), label: 'Contenuti creati'),
          ],
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 260,
          child: Stack(
            key: _stackKey,
            clipBehavior: Clip.none,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  const spacing = 14.0;
                  const minGroupWidth = 72.0;
                  final count = widget.trend.length;
                  final requiredMinWidth =
                      (count * minGroupWidth) + ((count - 1) * spacing);
                  final shouldScroll = requiredMinWidth > constraints.maxWidth;
                  final chartWidth = shouldScroll
                      ? requiredMinWidth
                      : constraints.maxWidth;
                  final groupWidth =
                      (chartWidth - ((count - 1) * spacing)) / count;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: chartWidth,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: widget.trend.asMap().entries.map((entry) {
                          final index = entry.key;
                          final point = entry.value;

                          return Padding(
                            padding: EdgeInsets.only(
                              right: index == count - 1 ? 0 : spacing,
                            ),
                            child: MouseRegion(
                              onEnter: (_) =>
                                  setState(() => hoveredIndex = index),
                              onExit: (_) =>
                                  setState(() => hoveredIndex = null),
                              child: SizedBox(
                                key: _groupKeyForIndex(index),
                                width: groupWidth,
                                child: _TrendGroup(
                                  point: point,
                                  maxValue: maxValue,
                                  hovered: hoveredIndex == index,
                                  onHoverChanged: (_) {},
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),

              if (hoveredIndex != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final left = _tooltipLeft(constraints.maxWidth);
                        if (left == null) return const SizedBox.shrink();

                        return Stack(
                          children: [
                            Positioned(
                              top: 0,
                              left: left,
                              child: _TrendInfoCard(
                                point: widget.trend[hoveredIndex!],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TrendGroup extends StatefulWidget {
  final DashboardTrendPoint point;
  final double maxValue;
  final bool hovered;
  final ValueChanged<bool> onHoverChanged;

  const _TrendGroup({
    required this.point,
    required this.maxValue,
    required this.hovered,
    required this.onHoverChanged,
  });

  @override
  State<_TrendGroup> createState() => _TrendGroupState();
}

class _TrendGroupState extends State<_TrendGroup> {
  @override
  Widget build(BuildContext context) {
    final point = widget.point;
    final maxValue = widget.maxValue;

    final activeHeight = 150 * (point.activeUsers / maxValue);
    final contentHeight = 150 * (point.contentCreated / maxValue);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => widget.onHoverChanged(true),
      onExit: (_) => widget.onHoverChanged(false),
      child: AnimatedScale(
        scale: widget.hovered ? 1.06 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SizedBox(
            height: 220,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: 170,
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _TrendBar(
                        height: activeHeight,
                        color: const Color(0xFF4F46E5),
                        highlighted: widget.hovered,
                      ),
                      const SizedBox(width: 6),
                      _TrendBar(
                        height: contentHeight,
                        color: const Color(0xFFEC4899),
                        highlighted: widget.hovered,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _dayLabel(point.date),
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.hovered
                        ? const Color(0xFF111827)
                        : Colors.grey,
                    fontWeight: widget.hovered
                        ? FontWeight.w700
                        : FontWeight.w500,
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

class _TrendInfoCard extends StatelessWidget {
  static const double cardWidth = 160;
  final DashboardTrendPoint? point;

  const _TrendInfoCard({required this.point});

  @override
  Widget build(BuildContext context) {
    final p = point;
    if (p == null) return const SizedBox(width: 220);

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7EAF0)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 16,
            offset: Offset(0, 6),
            color: Color(0x12000000),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Text(
                _dayLabel(p.date),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(
                formatDate(p.date, format: 'dd/MM'),
                style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
              ),
            ],
          ),

          const SizedBox(width: 18),
          _MiniStat(label: 'Attivi', value: p.activeUsers),
          const SizedBox(width: 6),
          _MiniStat(label: 'Contenuti', value: p.contentCreated),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF9CA3AF),
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}

// ignore: unused_element
class _TrendMiniStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _TrendMiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _TrendBar extends StatelessWidget {
  final double height;
  final Color color;
  final bool highlighted;

  const _TrendBar({
    required this.height,
    required this.color,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: highlighted ? 16 : 14,
      height: height.clamp(12, 150),
      decoration: BoxDecoration(
        color: color.withValues(alpha: highlighted ? 1.0 : 0.82),
        borderRadius: BorderRadius.circular(999),
        boxShadow: highlighted
            ? [
                BoxShadow(
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                  color: color.withValues(alpha: 0.28),
                ),
              ]
            : const [],
      ),
    );
  }
}

class _TrendLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _TrendLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    final actions = const [
      _QuickAction(
        title: 'Crea utente',
        subtitle: 'Aggiungi un operatore o un editor',
        icon: Icons.person_add_alt_1_rounded,
        color: Color(0xFF4F46E5),
      ),
      _QuickAction(
        title: 'Crea evento',
        subtitle: 'Pianifica una nuova diretta o campagna',
        icon: Icons.event_available_rounded,
        color: Color(0xFF14B8A6),
      ),
      _QuickAction(
        title: 'Aggiungi contenuto',
        subtitle: 'Collega media o post a un evento',
        icon: Icons.upload_rounded,
        color: Color(0xFFEC4899),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 1000
            ? 3
            : constraints.maxWidth >= 700
            ? 2
            : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 3.2,
          ),
          itemBuilder: (context, index) {
            return _QuickActionCard(action: actions[index]);
          },
        );
      },
    );
  }
}

class _QuickActionCard extends StatefulWidget {
  final _QuickAction action;

  const _QuickActionCard({required this.action});

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final action = widget.action;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: RepaintBoundary(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: hovered ? 1 : 0),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          builder: (context, t, child) {
            return Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE7EAF0)),
                  ),
                  child: child,
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: action.color.withValues(alpha: 0.08 * t),
                        border: Border.all(
                          color: action.color.withValues(alpha: 0.24 * t),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: action.color.withValues(alpha: 0.14),
                ),
                child: Icon(action.icon, color: action.color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      action.title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      action.subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SkeletonBar(width: 260, height: 34),
          const SizedBox(height: 10),
          const _SkeletonBar(width: 320, height: 18),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(
              2,
              (_) => const _SkeletonPill(width: 220, height: 44),
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth >= 900 ? 4 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.8,
                ),
                itemBuilder: (_, _) => const _MetricSkeleton(),
              );
            },
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 1200) {
                return const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _PanelSkeleton(lines: 4)),
                    SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
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
                children: [
                  _PanelSkeleton(lines: 4),
                  SizedBox(height: 20),
                  _PanelSkeleton(lines: 4),
                  SizedBox(height: 20),
                  _PanelSkeleton(lines: 4),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          const _PanelSkeleton(lines: 5),
          const SizedBox(height: 20),
          const _PanelSkeleton(lines: 3),
        ],
      ),
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
        border: Border.all(color: const Color(0xFFE7EAF0)),
      ),
      child: Row(
        children: const [
          _SkeletonPill(width: 52, height: 52),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
        border: Border.all(color: const Color(0xFFE7EAF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SkeletonBar(width: 160, height: 18),
          const SizedBox(height: 6),
          const _SkeletonBar(width: 220, height: 12),
          const SizedBox(height: 16),
          ...List.generate(
            lines,
            (index) => Padding(
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
          color: const Color(0xFFE6E6E6),
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
          color: const Color(0xFFE6E6E6),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DashboardError({required this.message, required this.onRetry});

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
          children: [
            const Icon(Icons.error_rounded, size: 42, color: Color(0xFFEF4444)),
            const SizedBox(height: 12),
            const Text(
              'Failed to load dashboard',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _MetricCardData {
  final String title;
  final String value;
  final String detail;
  final IconData icon;
  final Color accent;

  const _MetricCardData({
    required this.title,
    required this.value,
    required this.detail,
    required this.icon,
    required this.accent,
  });
}

class _QuickAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

String _dayLabel(DateTime date) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return days[date.weekday - 1];
}

String _formatShortDateTime(DateTime date) {
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  final h = date.hour.toString().padLeft(2, '0');
  final min = date.minute.toString().padLeft(2, '0');
  return '$d/$m $h:$min';
}

IconData _activityIcon(String type) {
  switch (type) {
    case 'live':
      return Icons.podcasts_rounded;
    case 'event':
      return Icons.event_rounded;
    case 'image':
      return Icons.image_rounded;
    case 'video':
      return Icons.videocam_rounded;
    case 'post':
      return Icons.article_rounded;
    case 'login':
      return Icons.login_rounded;
    case 'edit':
      return Icons.edit_rounded;
    case 'upload':
      return Icons.cloud_upload_rounded;
    case 'delete':
      return Icons.delete_outline_rounded;
    default:
      return Icons.bolt_rounded;
  }
}

Color _activityColor(String type) {
  switch (type) {
    case 'live':
      return const Color(0xFFEF4444);
    case 'event':
      return const Color(0xFFF59E0B);
    case 'image':
      return const Color(0xFF14B8A6);
    case 'video':
      return const Color(0xFF4F46E5);
    case 'post':
      return const Color(0xFFEC4899);
    case 'login':
      return const Color(0xFF14B8A6);
    case 'edit':
      return const Color(0xFF4F46E5);
    case 'upload':
      return const Color(0xFFEC4899);
    case 'delete':
      return const Color(0xFFEF4444);
    default:
      return const Color(0xFFF59E0B);
  }
}

String _focusStatusLabel(String status, bool needsAttention) {
  if (needsAttention) {
    return 'Da completare';
  }

  switch (status) {
    case 'live':
      return 'Live';
    case 'ended':
      return 'Concluso';
    default:
      return 'Pronto';
  }
}

Color _focusStatusColor(String status, bool needsAttention) {
  if (needsAttention) {
    return const Color(0xFFF59E0B);
  }

  switch (status) {
    case 'live':
      return const Color(0xFFEF4444);
    case 'ended':
      return const Color(0xFF64748B);
    default:
      return const Color(0xFF22C55E);
  }
}
