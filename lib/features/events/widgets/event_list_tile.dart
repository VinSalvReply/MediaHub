import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mediahub/features/users/models/event.dart';

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
    final formatter = DateFormat('dd MMM yyyy · HH:mm');
    final statusChip = _StatusChip(status: event.status);
    final attendeesChip = _AttendeesChip(count: event.attendees);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7EAF0)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 8),
            color: Color(0x10000000),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 860;

          Widget details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                maxLines: compact ? 2 : 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formatter.format(event.date),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
              ),
              if (event.contents.isNotEmpty) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEC4899).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        event.contents.length == 1
                            ? '1 contenuto'
                            : '${event.contents.length} contenuti',
                        style: const TextStyle(
                          color: Color(0xFFBE185D),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    ...event.contents
                        .take(2)
                        .map(
                          (content) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              content.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                  ],
                ),
              ],
              if (event.userId != null) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Utente #${event.userId}',
                    style: const TextStyle(
                      color: Color(0xFF4F46E5),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          );

          Widget leadingIcon = Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: const Color(0xFF14B8A6).withValues(alpha: 0.12),
            ),
            child: const Icon(Icons.event_rounded, color: Color(0xFF14B8A6)),
          );

          Widget menuButton = _EventMenuButton(
            onEdit: onEdit,
            onDelete: onDelete,
          );

          Widget assignButton = SizedBox.shrink();
          if (event.userId != null && onUnassign != null) {
            // Assegnato: mostra icona di rimozione
            assignButton = SizedBox(
              height: 40,
              child: Tooltip(
                message: 'Rimuovi assegnazione',
                child: IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Rimuovere assegnazione?'),
                        content: const Text(
                          'L\'evento sarà disassegnato dall\'utente.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Annulla'),
                          ),
                          FilledButton.tonal(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Rimuovi'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      onUnassign!();
                    }
                  },
                  iconSize: 20,
                  color: const Color(0xFFEF4444),
                ),
              ),
            );
          } else if (event.userId == null && onAssign != null) {
            // Non assegnato: mostra icona di aggiunta
            assignButton = SizedBox(
              height: 40,
              child: Tooltip(
                message: 'Assegna utente',
                child: IconButton(
                  icon: const Icon(Icons.person_add_rounded),
                  onPressed: onAssign,
                  iconSize: 20,
                  color: const Color(0xFF4F46E5),
                ),
              ),
            );
          }

          final body = !compact
              ? Row(
                  children: [
                    leadingIcon,
                    const SizedBox(width: 14),
                    Expanded(child: details),
                    statusChip,
                    const SizedBox(width: 12),
                    attendeesChip,
                    const SizedBox(width: 4),
                    assignButton,
                    const SizedBox(width: 4),
                    menuButton,
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        leadingIcon,
                        const SizedBox(width: 12),
                        Expanded(child: details),
                        assignButton,
                        menuButton,
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [statusChip, attendeesChip],
                    ),
                  ],
                );

          if (footer == null) {
            return body;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [body, const SizedBox(height: 12), footer!],
          );
        },
      ),
    );
  }
}

class _EventMenuButton extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EventMenuButton({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_EventAction>(
      onSelected: (action) {
        if (action == _EventAction.edit) onEdit();
        if (action == _EventAction.delete) onDelete();
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: _EventAction.edit,
          child: Row(
            children: [
              Icon(Icons.edit_rounded, size: 18),
              SizedBox(width: 10),
              Text('Modifica'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: _EventAction.delete,
          child: Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                size: 18,
                color: Color(0xFFEF4444),
              ),
              SizedBox(width: 10),
              Text('Elimina', style: TextStyle(color: Color(0xFFEF4444))),
            ],
          ),
        ),
      ],
      icon: const Icon(
        Icons.more_vert_rounded,
        size: 20,
        color: Color(0xFF9CA3AF),
      ),
      tooltip: '',
      splashRadius: 18,
    );
  }
}

enum _EventAction { edit, delete }

class _StatusChip extends StatelessWidget {
  final EventStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      EventStatus.upcoming => const Color(0xFF4F46E5),
      EventStatus.live => const Color(0xFF22C55E),
      EventStatus.ended => const Color(0xFF9CA3AF),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
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

class _AttendeesChip extends StatelessWidget {
  final int count;

  const _AttendeesChip({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.people_alt_rounded,
          size: 16,
          color: Color(0xFF6B7280),
        ),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
