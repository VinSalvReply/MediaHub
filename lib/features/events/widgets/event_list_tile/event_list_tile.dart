import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mediahub/core/constants/color.dart';
import 'package:mediahub/features/contents/models/content_item.dart';
import 'package:mediahub/features/events/models/event.dart';
import 'package:mediahub/features/events/widgets/event_list_tile/event_list_badges.dart';
import 'package:mediahub/features/events/widgets/event_list_tile/event_menu_button.dart';

/// Responsive event row with status, attendees, assignment, and actions.
class EventListTile extends StatelessWidget {
  final Event event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onAssign;
  final VoidCallback? onUnassign;
  final Widget? footer;

  const EventListTile({
    super.key,
    required this.event,
    required this.onEdit,
    required this.onDelete,
    this.onAssign,
    this.onUnassign,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 8),
            color: eventCardShadowColor,
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool compact = constraints.maxWidth < 860;
          final Widget details = _EventDetails(event: event, compact: compact);
          final Widget assignmentAction = _AssignmentAction(
            event: event,
            onAssign: onAssign,
            onUnassign: onUnassign,
          );
          final Widget actions = Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              assignmentAction,
              const SizedBox(width: 4),
              EventMenuButton(onEdit: onEdit, onDelete: onDelete),
            ],
          );
          final Widget body = compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const _EventIcon(),
                        const SizedBox(width: 12),
                        Expanded(child: details),
                        actions,
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: <Widget>[
                        EventStatusBadge(status: event.status),
                        EventAttendeesBadge(count: event.attendees),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: <Widget>[
                    const _EventIcon(),
                    const SizedBox(width: 14),
                    Expanded(child: details),
                    EventStatusBadge(status: event.status),
                    const SizedBox(width: 12),
                    EventAttendeesBadge(count: event.attendees),
                    const SizedBox(width: 8),
                    actions,
                  ],
                );

          return footer == null
              ? body
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[body, const SizedBox(height: 12), footer!],
                );
        },
      ),
    );
  }
}

class _EventDetails extends StatelessWidget {
  final Event event;
  final bool compact;

  const _EventDetails({required this.event, required this.compact});

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('dd MMM yyyy · HH:mm');
    final List<Widget> contentTags = event.contents
        .take(2)
        .map(
          (ContentItem content) =>
              _Tag(label: content.title, color: eventInputSurfaceColor),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          event.title,
          maxLines: compact ? 2 : 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          formatter.format(event.date),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: textMutedColor, fontSize: 13),
        ),
        if (event.contents.isNotEmpty) ...<Widget>[
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: <Widget>[
              _Tag(
                label: event.contents.length == 1
                    ? '1 contenuto'
                    : '${event.contents.length} contenuti',
                color: accentPinkColor.withValues(alpha: 0.12),
                textColor: eventContentAccentColor,
              ),
              ...contentTags,
            ],
          ),
        ],
        if (event.userId != null) ...<Widget>[
          const SizedBox(height: 6),
          _Tag(
            label: 'Utente #${event.userId}',
            color: primaryColor.withValues(alpha: 0.1),
            textColor: primaryColor,
          ),
        ],
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;

  const _Tag({required this.label, required this.color, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          fontWeight: textColor == null ? FontWeight.w400 : FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}

class _EventIcon extends StatelessWidget {
  const _EventIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: successColor.withValues(alpha: 0.12),
      ),
      child: const Icon(Icons.event_rounded, color: successColor),
    );
  }
}

class _AssignmentAction extends StatelessWidget {
  final Event event;
  final VoidCallback? onAssign;
  final VoidCallback? onUnassign;

  const _AssignmentAction({
    required this.event,
    required this.onAssign,
    required this.onUnassign,
  });

  @override
  Widget build(BuildContext context) {
    if (event.userId != null && onUnassign != null) {
      return IconButton(
        tooltip: 'Rimuovi assegnazione',
        icon: const Icon(Icons.close_rounded),
        color: dangerColor,
        onPressed: () => _confirmUnassign(context),
      );
    }
    if (event.userId == null && onAssign != null) {
      return IconButton(
        tooltip: 'Assegna utente',
        icon: const Icon(Icons.person_add_rounded),
        color: primaryColor,
        onPressed: onAssign,
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> _confirmUnassign(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Rimuovere assegnazione?'),
        content: const Text('L\'evento sarà disassegnato dall\'utente.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annulla'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Rimuovi'),
          ),
        ],
      ),
    );
    if (confirm == true) onUnassign!();
  }
}
