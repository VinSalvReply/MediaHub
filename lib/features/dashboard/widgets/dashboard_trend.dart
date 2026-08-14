import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mediahub/core/constants/animation.dart';
import 'package:mediahub/core/constants/color.dart';
import 'package:mediahub/core/utils/date.dart';
import 'package:mediahub/features/dashboard/models/dashboard_data.dart';

/// Interactive trend chart with hover support on desktop and tap support on phones.
class DashboardTrendPanel extends StatefulWidget {
  final List<DashboardTrendPoint> trend;

  const DashboardTrendPanel({super.key, required this.trend});

  @override
  State<DashboardTrendPanel> createState() => _DashboardTrendPanelState();
}

class _DashboardTrendPanelState extends State<DashboardTrendPanel> {
  static const double _chartHeight = 260;
  static const double _groupSpacing = 14;
  static const double _minimumGroupWidth = 72;

  int? _selectedIndex;
  final GlobalKey _chartKey = GlobalKey();
  final Map<int, GlobalKey> _groupKeys = <int, GlobalKey>{};

  @override
  Widget build(BuildContext context) {
    if (widget.trend.isEmpty) return const SizedBox.shrink();

    final bool isPhone = MediaQuery.sizeOf(context).width < 700;
    final double maxValue = widget.trend
        .map(
          (DashboardTrendPoint point) =>
              math.max(point.activeUsers, point.contentCreated),
        )
        .reduce(math.max)
        .toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _TrendLegendRow(),
        const SizedBox(height: 12),
        SizedBox(
          height: _chartHeight,
          child: Stack(
            key: _chartKey,
            clipBehavior: Clip.none,
            children: <Widget>[
              _ChartScroller(
                points: widget.trend,
                maxValue: maxValue,
                selectedIndex: _selectedIndex,
                isPhone: isPhone,
                groupSpacing: _groupSpacing,
                minimumGroupWidth: _minimumGroupWidth,
                groupKeyForIndex: _groupKeyForIndex,
                onSelect: _selectIndex,
              ),
              if (_selectedIndex != null) _buildTooltip(),
              if (isPhone && _selectedIndex != null)
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => _selectIndex(null),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  GlobalKey _groupKeyForIndex(int index) {
    return _groupKeys.putIfAbsent(index, GlobalKey.new);
  }

  void _selectIndex(int? index) {
    setState(() => _selectedIndex = _selectedIndex == index ? null : index);
  }

  Widget _buildTooltip() {
    final BuildContext? groupContext = _groupKeyForIndex(
      _selectedIndex!,
    ).currentContext;
    final BuildContext? chartContext = _chartKey.currentContext;
    if (groupContext == null || chartContext == null) {
      return const SizedBox.shrink();
    }

    final RenderBox? groupBox = groupContext.findRenderObject() as RenderBox?;
    final RenderBox? chartBox = chartContext.findRenderObject() as RenderBox?;
    if (groupBox == null || chartBox == null) {
      return const SizedBox.shrink();
    }

    const double tooltipWidth = _TrendInfoCard.width;
    final Offset center = groupBox.localToGlobal(
      groupBox.size.center(Offset.zero),
      ancestor: chartBox,
    );
    final double left = (center.dx - tooltipWidth / 2).clamp(
      0.0,
      math.max(0.0, chartBox.size.width - tooltipWidth),
    );

    return Positioned(
      top: 0,
      left: left,
      child: IgnorePointer(
        child: _TrendInfoCard(point: widget.trend[_selectedIndex!]),
      ),
    );
  }
}

class _ChartScroller extends StatelessWidget {
  final List<DashboardTrendPoint> points;
  final double maxValue;
  final int? selectedIndex;
  final bool isPhone;
  final double groupSpacing;
  final double minimumGroupWidth;
  final GlobalKey Function(int index) groupKeyForIndex;
  final ValueChanged<int?> onSelect;

  const _ChartScroller({
    required this.points,
    required this.maxValue,
    required this.selectedIndex,
    required this.isPhone,
    required this.groupSpacing,
    required this.minimumGroupWidth,
    required this.groupKeyForIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int count = points.length;
        final double minimumWidth =
            count * minimumGroupWidth + (count - 1) * groupSpacing;
        final double chartWidth = math.max(minimumWidth, constraints.maxWidth);
        final double groupWidth =
            (chartWidth - (count - 1) * groupSpacing) / count;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: chartWidth,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: points.asMap().entries.map((
                MapEntry<int, DashboardTrendPoint> entry,
              ) {
                final int index = entry.key;
                return Padding(
                  padding: EdgeInsets.only(
                    right: index == count - 1 ? 0 : groupSpacing,
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: isPhone ? () => onSelect(index) : null,
                    child: MouseRegion(
                      onEnter: isPhone ? null : (_) => onSelect(index),
                      onExit: isPhone ? null : (_) => onSelect(null),
                      child: SizedBox(
                        key: groupKeyForIndex(index),
                        width: groupWidth,
                        child: _TrendGroup(
                          point: entry.value,
                          maxValue: maxValue,
                          selected: selectedIndex == index,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class _TrendLegendRow extends StatelessWidget {
  const _TrendLegendRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: <Widget>[
        _TrendLegend(color: primaryColor, label: 'Utenti attivi'),
        SizedBox(width: 16),
        _TrendLegend(color: accentPinkColor, label: 'Contenuti creati'),
      ],
    );
  }
}

class _TrendGroup extends StatelessWidget {
  final DashboardTrendPoint point;
  final double maxValue;
  final bool selected;

  const _TrendGroup({
    required this.point,
    required this.maxValue,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final double activeHeight = 150 * point.activeUsers / maxValue;
    final double contentHeight = 150 * point.contentCreated / maxValue;

    return AnimatedScale(
      scale: selected ? 1.06 : 1,
      duration: AnimationConfig.hoverDuration,
      curve: Curves.easeOutCubic,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: SizedBox(
          height: 220,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              SizedBox(
                height: 170,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _TrendBar(
                      height: activeHeight,
                      color: primaryColor,
                      highlighted: selected,
                    ),
                    const SizedBox(width: 6),
                    _TrendBar(
                      height: contentHeight,
                      color: accentPinkColor,
                      highlighted: selected,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _dayLabel(point.date),
                style: TextStyle(
                  fontSize: 12,
                  color: selected ? textPrimaryColor : Colors.grey,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrendInfoCard extends StatelessWidget {
  static const double width = 160;
  final DashboardTrendPoint point;

  const _TrendInfoCard({required this.point});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            blurRadius: 16,
            offset: Offset(0, 6),
            color: dashboardMediumShadowColor,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            children: <Widget>[
              Text(
                _dayLabel(point.date),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(
                formatDate(point.date, format: 'dd/MM'),
                style: const TextStyle(fontSize: 11, color: textMutedColor),
              ),
            ],
          ),
          const SizedBox(width: 18),
          _MiniStat(label: 'Attivi', value: point.activeUsers),
          const SizedBox(width: 6),
          _MiniStat(label: 'Contenuti', value: point.contentCreated),
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
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: textSubtleColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: textPrimaryColor,
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
      duration: AnimationConfig.hoverDuration,
      curve: Curves.easeOutCubic,
      width: highlighted ? 16 : 14,
      height: height.clamp(12, 150),
      decoration: BoxDecoration(
        color: color.withValues(alpha: highlighted ? 1 : 0.82),
        borderRadius: BorderRadius.circular(999),
        boxShadow: highlighted
            ? <BoxShadow>[
                BoxShadow(
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                  color: color.withValues(alpha: 0.28),
                ),
              ]
            : const <BoxShadow>[],
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
      children: <Widget>[
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
            color: textMutedColor,
          ),
        ),
      ],
    );
  }
}

String _dayLabel(DateTime date) {
  const List<String> days = <String>[
    'Lun',
    'Mar',
    'Mer',
    'Gio',
    'Ven',
    'Sab',
    'Dom',
  ];
  return days[date.weekday - 1];
}
