import 'package:flutter/material.dart';
import 'package:mediahub/core/constants/color.dart';
import 'package:mediahub/features/events/models/event_sort_mode.dart';

/// Opens the event sorting and lane display settings.
class EventsSettingsMenu extends StatelessWidget {
  final EventSortMode sortMode;
  final ValueChanged<EventSortMode?> onSortChanged;
  final bool splitAssigned;
  final ValueChanged<bool> onSplitChanged;

  const EventsSettingsMenu({
    super.key,
    required this.sortMode,
    required this.onSortChanged,
    required this.splitAssigned,
    required this.onSplitChanged,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Impostazioni',
      icon: const Icon(Icons.tune_rounded),
      onPressed: () => showDialog<void>(
        context: context,
        builder: (_) => _SettingsDialog(
          sortMode: sortMode,
          onSortChanged: onSortChanged,
          splitAssigned: splitAssigned,
          onSplitChanged: onSplitChanged,
        ),
      ),
    );
  }
}

class _SettingsDialog extends StatefulWidget {
  final EventSortMode sortMode;
  final ValueChanged<EventSortMode?> onSortChanged;
  final bool splitAssigned;
  final ValueChanged<bool> onSplitChanged;

  const _SettingsDialog({
    required this.sortMode,
    required this.onSortChanged,
    required this.splitAssigned,
    required this.onSplitChanged,
  });

  @override
  State<_SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<_SettingsDialog> {
  late EventSortMode _sortMode;
  late bool _splitAssigned;

  @override
  void initState() {
    super.initState();
    _sortMode = widget.sortMode;
    _splitAssigned = widget.splitAssigned;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340, maxHeight: 320),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Impostazioni',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    iconSize: 20,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Ordinamento',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<EventSortMode>(
                initialValue: _sortMode,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: const <DropdownMenuItem<EventSortMode>>[
                  DropdownMenuItem<EventSortMode>(
                    value: EventSortMode.nameAsc,
                    child: Text('Nome A-Z'),
                  ),
                  DropdownMenuItem<EventSortMode>(
                    value: EventSortMode.nameDesc,
                    child: Text('Nome Z-A'),
                  ),
                  DropdownMenuItem<EventSortMode>(
                    value: EventSortMode.dateAsc,
                    child: Text('Data crescente'),
                  ),
                  DropdownMenuItem<EventSortMode>(
                    value: EventSortMode.dateDesc,
                    child: Text('Data decrescente'),
                  ),
                ],
                onChanged: (EventSortMode? value) {
                  if (value == null) return;
                  setState(() => _sortMode = value);
                  widget.onSortChanged(value);
                },
              ),
              const SizedBox(height: 12),
              const Text(
                'Visualizzazione',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: dashboardSubtleSurfaceColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: <Widget>[
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Dividi vista',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Assegnati / Non assegnati',
                            style: TextStyle(
                              fontSize: 10,
                              color: textMutedColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _splitAssigned,
                      onChanged: (bool value) {
                        setState(() => _splitAssigned = value);
                        widget.onSplitChanged(value);
                      },
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
