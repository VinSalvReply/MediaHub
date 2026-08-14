import 'package:flutter/material.dart';
import 'package:mediahub/core/constants/color.dart';
import 'package:mediahub/core/utils/date.dart';
import 'package:mediahub/features/dashboard/models/dashboard_data.dart';

/// Recent activity feed shown in the main dashboard column.
class DashboardActivityFeed extends StatelessWidget {
  final List<DashboardActivity> items;

  const DashboardActivityFeed({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.asMap().entries.map((
        MapEntry<int, DashboardActivity> entry,
      ) {
        final bool isLast = entry.key == items.length - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
          child: _ActivityRow(item: entry.value),
        );
      }).toList(),
    );
  }
}

/// Single activity item with an intentionally lightweight hover state.
class _ActivityRow extends StatefulWidget {
  final DashboardActivity item;

  const _ActivityRow({required this.item});

  @override
  State<_ActivityRow> createState() => _ActivityRowState();
}

class _ActivityRowState extends State<_ActivityRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final DashboardActivity item = widget.item;
    final Color color = _activityColor(item.type);

    return RepaintBoundary(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _isHovered
                ? DashboardColors.subtleSurface
                : DashboardColors.activitySurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: DashboardColors.border),
          ),
          child: Row(
            children: <Widget>[
              _ActivityIcon(icon: _activityIcon(item.type), color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
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

class _ActivityIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _ActivityIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: color.withValues(alpha: 0.12),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

/// Progress bars that summarize the dashboard's editorial insights.
class DashboardInsightsPanel extends StatelessWidget {
  final List<DashboardInsight> items;

  const DashboardInsightsPanel({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    const List<Color> palette = <Color>[
      DashboardColors.activeUsers,
      DashboardColors.media,
      DashboardColors.contentCreated,
      DashboardColors.published,
    ];

    return Column(
      children: items.asMap().entries.map((
        MapEntry<int, DashboardInsight> entry,
      ) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _InsightBar(
            item: entry.value,
            color: palette[entry.key % palette.length],
          ),
        );
      }).toList(),
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
        color: DashboardColors.subtleSurface,
        border: Border.all(color: DashboardColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
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

/// Events that require attention from the editorial or media team.
class DashboardFocusEventsPanel extends StatelessWidget {
  final List<DashboardFocusEvent> events;

  const DashboardFocusEventsPanel({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: events.asMap().entries.map((
        MapEntry<int, DashboardFocusEvent> entry,
      ) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: entry.key == events.length - 1 ? 0 : 12,
          ),
          child: _FocusEventTile(event: entry.value),
        );
      }).toList(),
    );
  }
}

/// Displays completion progress and the operational status of one event.
class _FocusEventTile extends StatelessWidget {
  final DashboardFocusEvent event;

  const _FocusEventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final double progress = event.contentCount == 0
        ? 0.0
        : event.publishedCount / event.contentCount;
    final Color color = _focusStatusColor(event.status, event.needsAttention);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: DashboardColors.subtleSurface,
        border: Border.all(color: DashboardColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _focusStatusLabel(event.status, event.needsAttention),
                  style: TextStyle(
                    color: color,
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
                  color: DashboardColors.mutedText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${event.contentCount} contenuti, ${event.publishedCount} pubblicati, ${event.mediaCount} media collegati',
            style: const TextStyle(
              color: DashboardColors.mutedText,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: progress,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatShortDateTime(DateTime date) {
  final String day = date.day.toString().padLeft(2, '0');
  final String month = date.month.toString().padLeft(2, '0');
  final String hour = date.hour.toString().padLeft(2, '0');
  final String minute = date.minute.toString().padLeft(2, '0');
  return '$day/$month $hour:$minute';
}

IconData _activityIcon(String type) => switch (type) {
  'live' => Icons.podcasts_rounded,
  'event' => Icons.event_rounded,
  'image' => Icons.image_rounded,
  'video' => Icons.videocam_rounded,
  'post' => Icons.article_rounded,
  'login' => Icons.login_rounded,
  'edit' => Icons.edit_rounded,
  'upload' => Icons.cloud_upload_rounded,
  'delete' => Icons.delete_outline_rounded,
  _ => Icons.bolt_rounded,
};

Color _activityColor(String type) => switch (type) {
  'live' => DashboardColors.live,
  'event' => DashboardColors.event,
  'image' => DashboardColors.media,
  'video' => DashboardColors.activeUsers,
  'post' => DashboardColors.contentCreated,
  'login' => DashboardColors.media,
  'edit' => DashboardColors.activeUsers,
  'upload' => DashboardColors.contentCreated,
  'delete' => DashboardColors.live,
  _ => DashboardColors.event,
};

String _focusStatusLabel(String status, bool needsAttention) {
  if (needsAttention) return 'Da completare';
  return switch (status) {
    'live' => 'Live',
    'ended' => 'Concluso',
    _ => 'Pronto',
  };
}

Color _focusStatusColor(String status, bool needsAttention) {
  if (needsAttention) return DashboardColors.event;
  return switch (status) {
    'live' => DashboardColors.live,
    'ended' => DashboardColors.neutral,
    _ => DashboardColors.published,
  };
}
