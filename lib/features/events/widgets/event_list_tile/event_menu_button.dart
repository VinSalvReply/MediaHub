import 'package:flutter/material.dart';
import 'package:mediahub/core/constants/color.dart';

enum _EventAction { edit, delete }

/// Context menu for event edit and delete actions.
class EventMenuButton extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EventMenuButton({
    super.key,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_EventAction>(
      tooltip: 'Azioni evento',
      onSelected: (_EventAction action) {
        switch (action) {
          case _EventAction.edit:
            onEdit();
          case _EventAction.delete:
            onDelete();
        }
      },
      itemBuilder: (BuildContext context) =>
          const <PopupMenuEntry<_EventAction>>[
            PopupMenuItem<_EventAction>(
              value: _EventAction.edit,
              child: _MenuRow(icon: Icons.edit_rounded, label: 'Modifica'),
            ),
            PopupMenuItem<_EventAction>(
              value: _EventAction.delete,
              child: _MenuRow(
                icon: Icons.delete_outline_rounded,
                label: 'Elimina',
                color: dangerColor,
              ),
            ),
          ],
      icon: const Icon(
        Icons.more_vert_rounded,
        size: 20,
        color: textSubtleColor,
      ),
      splashRadius: 18,
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MenuRow({
    required this.icon,
    required this.label,
    this.color = textPrimaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }
}
