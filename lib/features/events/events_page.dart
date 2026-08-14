import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mediahub/core/constants/animation.dart';
import 'package:mediahub/core/constants/color.dart';
import 'package:mediahub/core/utils/preserved_tween_animation_builder.dart';
import 'package:mediahub/core/widgets/page_error.dart';
import 'package:mediahub/features/events/controllers/events_controller.dart';
import 'package:mediahub/features/events/models/event.dart';
import 'package:mediahub/features/events/models/event_sort_mode.dart';
import 'package:mediahub/features/events/widgets/events_header.dart';
import 'package:mediahub/features/events/widgets/events_settings.dart';
import 'package:mediahub/features/events/widgets/quick_assign_bottom_sheet.dart';
import 'package:mediahub/features/events/widgets/event_form/event_form_dialog.dart';
import 'package:mediahub/features/events/widgets/event_list_tile/event_list_tile.dart';

const Color _backgroundColor = appBackgroundColor;
const Color _mutedTextColor = textMutedColor;

enum _SplitLane { all, assigned, unassigned }

/// Events page: owns CRUD actions and coordinates the event workspace.
class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late final EventsController _controller;
  EventSortMode _sortMode = EventSortMode.dateAsc;
  bool _splitAssigned = false;
  bool _previousSplitAssigned = false;
  int _sortTick = 0;
  Map<int, int> _previousAllEventIndexes = const <int, int>{};
  Map<int, int> _previousAssignedEventIndexes = const <int, int>{};
  Map<int, int> _previousUnassignedEventIndexes = const <int, int>{};

  @override
  void initState() {
    super.initState();
    _controller = EventsController()..init();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, _) {
        final bool initialLoading =
            (_controller.isLoadingUsers || _controller.isLoadingEvents) &&
            _controller.events.isEmpty;
        if (initialLoading) {
          return const ColoredBox(
            color: _backgroundColor,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (_controller.errorMessage != null && _controller.events.isEmpty) {
          return ColoredBox(
            color: _backgroundColor,
            child: PageError(
              title: 'Impossibile caricare gli eventi',
              onRetry: _controller.loadEvents,
            ),
          );
        }

        return ColoredBox(
          color: _backgroundColor,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                EventsHeader(
                  onCreate: _openCreateDialog,
                  onRefresh: _controller.loadEvents,
                  isRefreshing: _controller.isLoadingEvents,
                ),
                const SizedBox(height: 24),
                _EventsWorkspace(
                  controller: _controller,
                  onUnassign: _unassign,
                  sortMode: _sortMode,
                  onSortChanged: _setSortMode,
                  splitAssigned: _splitAssigned,
                  previousSplitAssigned: _previousSplitAssigned,
                  onSplitChanged: _setSplitAssigned,
                  sortTick: _sortTick,
                  previousAllEventIndexes: _previousAllEventIndexes,
                  previousAssignedEventIndexes: _previousAssignedEventIndexes,
                  previousUnassignedEventIndexes:
                      _previousUnassignedEventIndexes,
                  onEdit: _openEditDialog,
                  onDelete: _confirmDelete,
                  onCreate: _openCreateDialog,
                  onOpenQuickAssign: _openQuickAssignSheet,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _setSortMode(EventSortMode? mode) {
    if (mode == null || mode == _sortMode) return;
    final List<Event> before = _sortedEventsFor(_sortMode);
    setState(() {
      _previousSplitAssigned = _splitAssigned;
      _previousAllEventIndexes = _indexByEventId(before);
      _previousAssignedEventIndexes = _indexByEventId(
        before.where((Event event) => event.userId != null).toList(),
      );
      _previousUnassignedEventIndexes = _indexByEventId(
        before.where((Event event) => event.userId == null).toList(),
      );
      _sortMode = mode;
      _sortTick++;
    });
  }

  List<Event> _sortedEventsFor(EventSortMode mode) {
    return <Event>[..._controller.events]..sort((Event a, Event b) {
      switch (mode) {
        case EventSortMode.nameAsc:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case EventSortMode.nameDesc:
          return b.title.toLowerCase().compareTo(a.title.toLowerCase());
        case EventSortMode.dateAsc:
          return a.date.compareTo(b.date);
        case EventSortMode.dateDesc:
          return b.date.compareTo(a.date);
      }
    });
  }

  Map<int, int> _indexByEventId(List<Event> events) {
    return <int, int>{for (int i = 0; i < events.length; i++) events[i].id: i};
  }

  void _setSplitAssigned(bool value) {
    if (_splitAssigned == value) return;
    setState(() {
      _previousSplitAssigned = _splitAssigned;
      _splitAssigned = value;
      _sortTick++;
    });
  }

  Future<void> _openCreateDialog() async {
    final EventFormResult? result = await showDialog<EventFormResult>(
      context: context,
      builder: (_) => const EventFormDialog(),
    );
    if (result == null) return;
    final bool ok = await _controller.addEvent(
      title: result.title,
      date: result.date,
      attendees: result.attendees,
      status: result.status,
      contents: result.contents,
    );
    _toast(
      ok
          ? 'Evento creato'
          : (_controller.errorMessage ?? 'Salvataggio fallito'),
    );
  }

  Future<void> _openEditDialog(Event event) async {
    final EventFormResult? result = await showDialog<EventFormResult>(
      context: context,
      builder: (_) => EventFormDialog(initial: event),
    );
    if (result == null) return;
    final bool ok = await _controller.editEvent(
      original: event,
      title: result.title,
      date: result.date,
      attendees: result.attendees,
      status: result.status,
      contents: result.contents,
    );
    _toast(
      ok
          ? 'Evento aggiornato'
          : (_controller.errorMessage ?? 'Aggiornamento fallito'),
    );
  }

  Future<void> _unassign(Event event) async {
    final bool ok = await _controller.assignEventToUser(event, null);
    if (mounted) {
      _toast(
        ok
            ? 'Evento disassegnato'
            : (_controller.errorMessage ?? 'Operazione fallita'),
      );
    }
  }

  Future<void> _openQuickAssignSheet(Event event) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.transparent,
      builder: (BuildContext sheetContext) => QuickAssignBottomSheet(
        event: event,
        users: _controller.users,
        onAssign: (int? userId) async {
          final bool ok = await _controller.assignEventToUser(event, userId);
          if (!mounted) return;
          _toast(
            ok
                ? 'Evento assegnato'
                : (_controller.errorMessage ?? 'Assegnazione fallita'),
          );
          if (sheetContext.mounted) Navigator.pop(sheetContext);
        },
      ),
    );
  }

  Future<void> _confirmDelete(Event event) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Eliminare evento?'),
        content: Text('"${event.title}" verrà rimosso definitivamente.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annulla'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final bool ok = await _controller.removeEvent(event);
    _toast(
      ok
          ? 'Evento eliminato'
          : (_controller.errorMessage ?? 'Eliminazione fallita'),
    );
  }

  void _toast(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Shared surface used by the event workspace and its empty state.
class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _Card({required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            blurRadius: 20,
            offset: Offset(0, 8),
            color: eventCardShadowColor,
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Connects page callbacks to the sorted event workspace.
class _EventsWorkspace extends StatelessWidget {
  final EventsController controller;
  final Future<void> Function(Event event) onUnassign;
  final EventSortMode sortMode;
  final ValueChanged<EventSortMode?> onSortChanged;
  final bool splitAssigned;
  final bool previousSplitAssigned;
  final ValueChanged<bool> onSplitChanged;
  final int sortTick;
  final Map<int, int> previousAllEventIndexes;
  final Map<int, int> previousAssignedEventIndexes;
  final Map<int, int> previousUnassignedEventIndexes;
  final ValueChanged<Event> onEdit;
  final ValueChanged<Event> onDelete;
  final VoidCallback onCreate;
  final ValueChanged<Event> onOpenQuickAssign;

  const _EventsWorkspace({
    required this.controller,
    required this.onUnassign,
    required this.sortMode,
    required this.onSortChanged,
    required this.splitAssigned,
    required this.previousSplitAssigned,
    required this.onSplitChanged,
    required this.sortTick,
    required this.previousAllEventIndexes,
    required this.previousAssignedEventIndexes,
    required this.previousUnassignedEventIndexes,
    required this.onEdit,
    required this.onDelete,
    required this.onCreate,
    required this.onOpenQuickAssign,
  });

  @override
  Widget build(BuildContext context) {
    return _EventsBody(
      controller: controller,
      sortMode: sortMode,
      onSortChanged: onSortChanged,
      splitAssigned: splitAssigned,
      previousSplitAssigned: previousSplitAssigned,
      onSplitChanged: onSplitChanged,
      sortTick: sortTick,
      previousAllEventIndexes: previousAllEventIndexes,
      previousAssignedEventIndexes: previousAssignedEventIndexes,
      previousUnassignedEventIndexes: previousUnassignedEventIndexes,
      onEdit: onEdit,
      onDelete: onDelete,
      onCreate: onCreate,
      onUnassign: onUnassign,
      onOpenQuickAssign: onOpenQuickAssign,
    );
  }
}

/// Builds the sorted lanes and preserves reorder transitions.
class _EventsBody extends StatelessWidget {
  final EventsController controller;
  final EventSortMode sortMode;
  final ValueChanged<EventSortMode?> onSortChanged;
  final bool splitAssigned;
  final bool previousSplitAssigned;
  final ValueChanged<bool> onSplitChanged;
  final int sortTick;
  final Map<int, int> previousAllEventIndexes;
  final Map<int, int> previousAssignedEventIndexes;
  final Map<int, int> previousUnassignedEventIndexes;
  final ValueChanged<Event> onEdit;
  final ValueChanged<Event> onDelete;
  final VoidCallback onCreate;
  final Future<void> Function(Event event) onUnassign;
  final ValueChanged<Event> onOpenQuickAssign;

  const _EventsBody({
    required this.controller,
    required this.sortMode,
    required this.onSortChanged,
    required this.splitAssigned,
    required this.previousSplitAssigned,
    required this.onSplitChanged,
    required this.sortTick,
    required this.previousAllEventIndexes,
    required this.previousAssignedEventIndexes,
    required this.previousUnassignedEventIndexes,
    required this.onEdit,
    required this.onDelete,
    required this.onCreate,
    required this.onUnassign,
    required this.onOpenQuickAssign,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.events.isEmpty) {
      return _Card(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: <Widget>[
            const Icon(
              Icons.event_busy_rounded,
              size: 48,
              color: textSubtleColor,
            ),
            const SizedBox(height: 12),
            const Text(
              'Nessun evento trovato',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            const Text(
              'Crea il primo evento globale per iniziare',
              style: TextStyle(color: _mutedTextColor),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nuovo evento'),
            ),
          ],
        ),
      );
    }

    final List<Event> sorted = <Event>[...controller.events]
      ..sort(_compareEvents);
    final List<Event> assigned = sorted
        .where((Event event) => event.userId != null)
        .toList();
    final List<Event> unassigned = sorted
        .where((Event event) => event.userId == null)
        .toList();

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Eventi',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
              EventsSettingsMenu(
                sortMode: sortMode,
                onSortChanged: onSortChanged,
                splitAssigned: splitAssigned,
                onSplitChanged: onSplitChanged,
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (!splitAssigned)
            Column(
              children: _buildEventCards(
                sorted,
                previousAllEventIndexes,
                lane: _SplitLane.all,
              ),
            )
          else
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool compact = constraints.maxWidth < 900;
                final List<Widget> assignedItems = _buildEventCards(
                  assigned,
                  previousAssignedEventIndexes,
                  lane: _SplitLane.assigned,
                );
                final List<Widget> unassignedItems = _buildEventCards(
                  unassigned,
                  previousUnassignedEventIndexes,
                  lane: _SplitLane.unassigned,
                );
                final Widget assignedLane = Column(
                  children: <Widget>[
                    _SplitSection(title: 'Assegnati', count: assigned.length),
                    ...assignedItems,
                  ],
                );
                final Widget unassignedLane = Column(
                  children: <Widget>[
                    _SplitSection(
                      title: 'Non assegnati',
                      count: unassigned.length,
                    ),
                    ...unassignedItems,
                  ],
                );
                return compact
                    ? Column(
                        children: <Widget>[
                          assignedLane,
                          const SizedBox(height: 10),
                          unassignedLane,
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(child: assignedLane),
                          const SizedBox(width: 12),
                          Expanded(child: unassignedLane),
                        ],
                      );
              },
            ),
          if (controller.isMutating)
            const Padding(
              padding: EdgeInsets.all(12),
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }

  int _compareEvents(Event a, Event b) {
    switch (sortMode) {
      case EventSortMode.nameAsc:
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      case EventSortMode.nameDesc:
        return b.title.toLowerCase().compareTo(a.title.toLowerCase());
      case EventSortMode.dateAsc:
        return a.date.compareTo(b.date);
      case EventSortMode.dateDesc:
        return b.date.compareTo(a.date);
    }
  }

  List<Widget> _buildEventCards(
    List<Event> source,
    Map<int, int> previousIndexes, {
    required _SplitLane lane,
  }) {
    const double itemStep = 122;
    return <Widget>[
      for (int index = 0; index < source.length; index++)
        Padding(
          key: ValueKey<String>('event-${source[index].id}-$sortTick'),
          padding: const EdgeInsets.only(bottom: 12),
          child: PreservedTweenAnimationBuilder(
            duration: AnimationConfig.reorderDuration(index),
            begin: 1,
            end: 0,
            curve: Curves.easeInOutCubicEmphasized,
            builder: (BuildContext context, double value, Widget? child) {
              final int? previousIndex = previousIndexes[source[index].id];
              final double offsetY = previousIndex == null
                  ? 0
                  : (previousIndex - index) * itemStep;
              final bool splitChanged = splitAssigned != previousSplitAssigned;
              final bool enteringUnassigned =
                  splitChanged &&
                  splitAssigned &&
                  lane == _SplitLane.unassigned;
              final bool leavingUnassigned =
                  splitChanged &&
                  !splitAssigned &&
                  lane == _SplitLane.all &&
                  source[index].userId == null;
              final double offsetX = enteringUnassigned
                  ? -220
                  : leavingUnassigned
                  ? 220
                  : 0;
              return Transform.translate(
                offset: Offset(offsetX * value, offsetY * value),
                child: EventListTile(
                  event: source[index],
                  onEdit: () => onEdit(source[index]),
                  onDelete: () => onDelete(source[index]),
                  onAssign: () => onOpenQuickAssign(source[index]),
                  onUnassign: () => onUnassign(source[index]),
                ),
              );
            },
          ),
        ),
    ];
  }
}

class _SplitSection extends StatelessWidget {
  final String title;
  final int count;

  const _SplitSection({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: dashboardSubtleSurfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Text('$count', style: const TextStyle(color: _mutedTextColor)),
        ],
      ),
    );
  }
}
