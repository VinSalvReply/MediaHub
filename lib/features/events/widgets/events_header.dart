import 'package:flutter/material.dart';
import 'package:mediahub/core/constants/color.dart';

/// Header for the events workspace with create and refresh actions.
class EventsHeader extends StatelessWidget {
  final VoidCallback onCreate;
  final VoidCallback onRefresh;
  final bool isRefreshing;

  const EventsHeader({
    super.key,
    required this.onCreate,
    required this.onRefresh,
    required this.isRefreshing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Eventi',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 6),
              Text(
                'Crea e modifica eventi',
                style: TextStyle(color: textMutedColor, fontSize: 14),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Aggiorna',
          onPressed: isRefreshing ? null : onRefresh,
          icon: isRefreshing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh_rounded),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          tooltip: 'Nuovo evento',
          onPressed: onCreate,
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    );
  }
}
