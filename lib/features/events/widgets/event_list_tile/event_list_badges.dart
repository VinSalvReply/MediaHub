import 'package:flutter/material.dart';
import 'package:mediahub/core/constants/color.dart';
import 'package:mediahub/features/events/models/event.dart';

/// Status badge used by an event list item.
class EventStatusBadge extends StatelessWidget {
  final EventStatus status;

  const EventStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final Color color = switch (status) {
      EventStatus.upcoming => primaryColor,
      EventStatus.live => dashboardPublishedColor,
      EventStatus.ended => textSubtleColor,
    };

    return _Pill(
      color: color,
      child: Text(
        status.name,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Attendee count shown beside the event status.
class EventAttendeesBadge extends StatelessWidget {
  final int count;

  const EventAttendeesBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(Icons.people_alt_rounded, size: 16, color: textMutedColor),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: const TextStyle(
            color: textMutedColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final Color color;
  final Widget child;

  const _Pill({required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: child,
    );
  }
}
