import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:mediahub/features/events/controllers/events_controller.dart';
import 'package:mediahub/features/events/widgets/event_form_dialog.dart';
import 'package:mediahub/features/events/widgets/event_list_tile.dart';
import 'package:mediahub/features/users/models/event.dart';

const _bgColor = Color(0xFFF5F7FB);
const _borderColor = Color(0xFFE7EAF0);
const _textMuted = Color(0xFF6B7280);

enum EventSortMode { nameAsc, nameDesc, dateAsc, dateDesc }

enum _SplitLane { all, assigned, unassigned }

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late final EventsController controller;
  EventSortMode _sortMode = EventSortMode.dateAsc;
  bool _splitAssigned = false;
  bool _previousSplitAssigned = false;
  int _sortTick = 0;
  Map<int, int> _previousAllEventIndexes = const {};
  Map<int, int> _previousAssignedEventIndexes = const {};
  Map<int, int> _previousUnassignedEventIndexes = const {};

  void _setSortMode(EventSortMode? mode) {
    if (mode == null || mode == _sortMode) return;
    final before = _sortedEventsFor(_sortMode);
    final beforeAssigned = before
        .where((event) => event.userId != null)
        .toList();
    final beforeUnassigned = before
        .where((event) => event.userId == null)
        .toList();
    setState(() {
      // A pure sort change should not trigger split lane transition animation.
      _previousSplitAssigned = _splitAssigned;
      _previousAllEventIndexes = _indexByEventId(before);
      _previousAssignedEventIndexes = _indexByEventId(beforeAssigned);
      _previousUnassignedEventIndexes = _indexByEventId(beforeUnassigned);
      _sortMode = mode;
      _sortTick++;
    });
  }

  List<Event> _sortedEventsFor(EventSortMode mode) {
    return [...controller.events]..sort((a, b) {
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
    return {for (var i = 0; i < events.length; i++) events[i].id: i};
  }

  void _setSplitAssigned(bool value) {
    if (_splitAssigned == value) return;
    setState(() {
      _previousSplitAssigned = _splitAssigned;
      _splitAssigned = value;
      _sortTick++;
    });
  }

  @override
  void initState() {
    super.initState();
    controller = EventsController()..init();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _openCreateDialog() async {
    final result = await showDialog<EventFormResult>(
      context: context,
      builder: (_) => const EventFormDialog(),
    );
    if (result == null) return;
    final ok = await controller.addEvent(
      title: result.title,
      date: result.date,
      attendees: result.attendees,
      status: result.status,
      contents: result.contents,
    );
    _toast(ok ? 'Evento creato' : (controller.error ?? 'Salvataggio fallito'));
  }

  Future<void> _openEditDialog(Event event) async {
    final result = await showDialog<EventFormResult>(
      context: context,
      builder: (_) => EventFormDialog(initial: event),
    );
    if (result == null) return;
    final ok = await controller.editEvent(
      original: event,
      title: result.title,
      date: result.date,
      attendees: result.attendees,
      status: result.status,
      contents: result.contents,
    );
    _toast(
      ok ? 'Evento aggiornato' : (controller.error ?? 'Aggiornamento fallito'),
    );
  }

  Future<void> _assign(Event event, int? userId) async {
    if (userId == null) return;
    final ok = await controller.assignEventToUser(event, userId);
    if (!mounted) return;
    _toast(
      ok
          ? 'Evento assegnato all\'utente'
          : (controller.error ?? 'Assegnazione fallita'),
    );
  }

  Future<void> _unassign(Event event) async {
    final ok = await controller.assignEventToUser(event, null);
    if (!mounted) return;
    _toast(
      ok ? 'Evento disassegnato' : (controller.error ?? 'Operazione fallita'),
    );
  }

  Future<void> _openQuickAssignSheet(Event event) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.transparent,
      builder: (ctx) => _QuickAssignBottomSheet(
        event: event,
        users: controller.users,
        onAssign: (userId) {
          if (userId == null) {
            _unassign(event);
          } else {
            _assign(event, userId);
          }
          Navigator.pop(ctx);
        },
      ),
    );
  }

  Future<void> _confirmDelete(Event event) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminare evento?'),
        content: Text('"${event.title}" verrà rimosso definitivamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final ok = await controller.removeEvent(event);
    _toast(
      ok ? 'Evento eliminato' : (controller.error ?? 'Eliminazione fallita'),
    );
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              color: _bgColor,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Header(
                          onCreate: _openCreateDialog,
                          onRefresh: controller.loadEvents,
                        ),
                        const SizedBox(height: 24),
                        _EventsWorkspace(
                          controller: controller,
                          onAssign: _assign,
                          onUnassign: _unassign,
                          sortMode: _sortMode,
                          onSortChanged: _setSortMode,
                          splitAssigned: _splitAssigned,
                          previousSplitAssigned: _previousSplitAssigned,
                          onSplitChanged: _setSplitAssigned,
                          sortTick: _sortTick,
                          previousAllEventIndexes: _previousAllEventIndexes,
                          previousAssignedEventIndexes:
                              _previousAssignedEventIndexes,
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
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onCreate;
  final VoidCallback onRefresh;

  const _Header({required this.onCreate, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Events',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Crea e modifica eventi',
                style: TextStyle(color: _textMuted, fontSize: 14),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Aggiorna',
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded),
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

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _Card({required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
        boxShadow: const [
          BoxShadow(
            blurRadius: 20,
            offset: Offset(0, 8),
            color: Color(0x0A000000),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _EventsWorkspace extends StatelessWidget {
  final EventsController controller;
  final Future<void> Function(Event event, int? userId) onAssign;
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
    required this.onAssign,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final enableDragDrop = constraints.maxWidth >= 700;

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
          enableDragDrop: enableDragDrop,
          onAssign: onAssign,
          onUnassign: onUnassign,
          onOpenQuickAssign: onOpenQuickAssign,
        );
      },
    );
  }
}

class _AssignmentSidebar extends StatefulWidget {
  final EventsController controller;
  final Future<void> Function(Event event, int? userId) onAssign;
  final VoidCallback onSidebarDragStart;
  final VoidCallback onDragEnd;
  final void Function(Event event, DraggableDetails details)
  onSidebarItemDragEnd;
  final ValueChanged<bool> onUserDropZoneHoverChanged;
  final ValueChanged<Offset> onDragCursorMove;
  final bool dragActive;

  const _AssignmentSidebar({
    required this.controller,
    required this.onAssign,
    required this.onSidebarDragStart,
    required this.onDragEnd,
    required this.onSidebarItemDragEnd,
    required this.onUserDropZoneHoverChanged,
    required this.onDragCursorMove,
    required this.dragActive,
  });

  @override
  State<_AssignmentSidebar> createState() => _AssignmentSidebarState();
}

class _AssignmentSidebarState extends State<_AssignmentSidebar> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _autoScrollOnEdge(PointerHoverEvent event) {
    autoScrollAt(event.position);
  }

  void autoScrollAt(Offset globalPosition) {
    if (!widget.dragActive) return;
    if (!_scrollController.hasClients) return;
    final box = context.findRenderObject();
    if (box is! RenderBox) return;
    final local = box.globalToLocal(globalPosition);
    if (local.dx < 0 || local.dx > box.size.width) return;
    final h = box.size.height;
    const edge = 56.0;
    double delta = 0;
    if (local.dy < edge) delta = -16;
    if (local.dy > h - edge) delta = 16;
    if (delta == 0) return;
    final max = _scrollController.position.maxScrollExtent;
    final next = (_scrollController.offset + delta).clamp(0.0, max);
    _scrollController.jumpTo(next);
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    if (controller.isLoadingUsers) {
      return const _Card(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return MouseRegion(
      onHover: _autoScrollOnEdge,
      child: _Card(
        padding: const EdgeInsets.all(14),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 420, maxHeight: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Utenti',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Trascina le card evento da sinistra verso un utente.',
                style: TextStyle(fontSize: 12, color: _textMuted),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    ...controller.users.map((user) {
                      final userEvents = controller.events
                          .where((event) => event.userId == user.id)
                          .toList();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _EventDropZone(
                          title: '${user.name} ${user.lastName}',
                          subtitle: user.email,
                          icon: Icons.person_rounded,
                          events: userEvents,
                          onDragStart: widget.onSidebarDragStart,
                          onDragEnd: widget.onSidebarItemDragEnd,
                          onUserDropZoneHoverChanged:
                              widget.onUserDropZoneHoverChanged,
                          onDragCursorMove: widget.onDragCursorMove,
                          onAccept: (event) => widget.onAssign(event, user.id),
                          scrollController: _scrollController,
                        ),
                      );
                    }),
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

class _EventDropZone extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final List<Event> events;
  final VoidCallback onDragStart;
  final void Function(Event event, DraggableDetails details) onDragEnd;
  final ValueChanged<bool> onUserDropZoneHoverChanged;
  final ValueChanged<Offset> onDragCursorMove;
  final ValueChanged<Event> onAccept;
  final ScrollController? scrollController;

  const _EventDropZone({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.events,
    required this.onDragStart,
    required this.onDragEnd,
    required this.onUserDropZoneHoverChanged,
    required this.onDragCursorMove,
    required this.onAccept,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<Event>(
      onWillAcceptWithDetails: (_) {
        onUserDropZoneHoverChanged(true);
        return true;
      },
      onMove: (details) {
        onUserDropZoneHoverChanged(true);
        // Auto-scroll quando il drag raggiunge i margini
        if (scrollController != null) {
          final box = context.findRenderObject() as RenderBox?;
          if (box != null) {
            final local = box.globalToLocal(details.offset);
            if (local.dy < 60 && scrollController!.offset > 0) {
              scrollController!.jumpTo(
                (scrollController!.offset - 20).clamp(
                  0.0,
                  scrollController!.position.maxScrollExtent,
                ),
              );
            } else if (local.dy > box.size.height - 60) {
              scrollController!.jumpTo(
                (scrollController!.offset + 20).clamp(
                  0.0,
                  scrollController!.position.maxScrollExtent,
                ),
              );
            }
          }
        }
      },
      onLeave: (_) => onUserDropZoneHoverChanged(false),
      onAcceptWithDetails: (details) {
        onUserDropZoneHoverChanged(false);
        onAccept(details.data);
      },
      builder: (context, candidateData, rejectedData) {
        final isActive = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFEEF2FF) : const Color(0xFFF8FAFC),
            border: Border.all(
              color: isActive
                  ? const Color(0xFF4F46E5)
                  : const Color(0xFFE7EAF0),
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: const Color(0xFF4F46E5)),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: _textMuted),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              if (events.isEmpty)
                const Text(
                  'Trascina qui un evento',
                  style: TextStyle(fontSize: 12, color: _textMuted),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: events
                      .map(
                        (event) => Draggable<Event>(
                          data: event,
                          onDragStarted: onDragStart,
                          onDragUpdate: (details) =>
                              onDragCursorMove(details.globalPosition),
                          onDragEnd: (details) => onDragEnd(event, details),
                          feedback: Material(
                            color: Colors.transparent,
                            child: _EventChip(event: event, dragging: true),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.45,
                            child: _EventChip(event: event),
                          ),
                          child: _EventChip(event: event),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _EventChip extends StatelessWidget {
  final Event event;
  final bool dragging;

  const _EventChip({required this.event, this.dragging = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: dragging ? const Color(0xFF4F46E5) : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE7EAF0)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 4),
            color: Color(0x12000000),
          ),
        ],
      ),
      child: Text(
        event.title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: dragging ? Colors.white : const Color(0xFF111827),
        ),
      ),
    );
  }
}

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
  final bool enableDragDrop;
  final Future<void> Function(Event event, int? userId) onAssign;
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
    required this.enableDragDrop,
    required this.onAssign,
    required this.onUnassign,
    required this.onOpenQuickAssign,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.isLoadingEvents) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (controller.error != null && controller.events.isEmpty) {
      return _Card(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 32),
            const SizedBox(height: 12),
            Text(controller.error!),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: controller.loadEvents,
              child: const Text('Riprova'),
            ),
          ],
        ),
      );
    }
    if (controller.events.isEmpty) {
      return _Card(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(
              Icons.event_busy_rounded,
              size: 48,
              color: Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 12),
            const Text(
              'Nessun evento trovato',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Crea il primo evento globale per iniziare',
              style: const TextStyle(color: _textMuted),
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

    final sorted = [...controller.events]
      ..sort((a, b) {
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
      });

    final assigned = sorted.where((e) => e.userId != null).toList();
    final unassigned = sorted.where((e) => e.userId == null).toList();

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Eventi',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
              _EventsSettingsMenu(
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
                context: context,
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final compactSplit = constraints.maxWidth < 900;
                if (compactSplit) {
                  return Column(
                    children: [
                      _SplitSection(title: 'Assegnati', count: assigned.length),
                      ..._buildEventCards(
                        assigned,
                        previousAssignedEventIndexes,
                        lane: _SplitLane.assigned,
                        context: context,
                      ),
                      const SizedBox(height: 10),
                      _SplitSection(
                        title: 'Non assegnati',
                        count: unassigned.length,
                      ),
                      ..._buildEventCards(
                        unassigned,
                        previousUnassignedEventIndexes,
                        lane: _SplitLane.unassigned,
                        context: context,
                      ),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _SplitSection(
                            title: 'Assegnati',
                            count: assigned.length,
                          ),
                          ..._buildEventCards(
                            assigned,
                            previousAssignedEventIndexes,
                            lane: _SplitLane.assigned,
                            context: context,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          _SplitSection(
                            title: 'Non assegnati',
                            count: unassigned.length,
                          ),
                          ..._buildEventCards(
                            unassigned,
                            previousUnassignedEventIndexes,
                            lane: _SplitLane.unassigned,
                            context: context,
                          ),
                        ],
                      ),
                    ),
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

  List<Widget> _buildEventCards(
    List<Event> source,
    Map<int, int> previousIndexes, {
    required _SplitLane lane,
    required BuildContext context,
  }) {
    const itemStep = 122.0;
    return [
      for (var i = 0; i < source.length; i++)
        Padding(
          key: ValueKey('event-${source[i].id}-$sortTick'),
          padding: const EdgeInsets.only(bottom: 12),
          child: TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 700 + (i * 35).clamp(0, 260)),
            tween: Tween(begin: 1, end: 0),
            curve: Curves.easeInOutCubicEmphasized,
            builder: (context, value, child) {
              final previousIndex = previousIndexes[source[i].id];
              final fromOffsetY = previousIndex == null
                  ? 0.0
                  : (previousIndex - i) * itemStep;
              final toggledSplit = splitAssigned != previousSplitAssigned;
              var fromOffsetX = 0.0;
              if (toggledSplit) {
                final isAssigned = source[i].userId != null;
                if (splitAssigned && lane == _SplitLane.unassigned) {
                  fromOffsetX = -220;
                }
                if (!splitAssigned && lane == _SplitLane.all && !isAssigned) {
                  fromOffsetX = 220;
                }
              }
              return Transform.translate(
                offset: Offset(fromOffsetX * value, fromOffsetY * value),
                child: EventListTile(
                  event: source[i],
                  onEdit: () => onEdit(source[i]),
                  onDelete: () => onDelete(source[i]),
                  onAssign: () => onOpenQuickAssign(source[i]),
                  onUnassign: () => onUnassign(source[i]),
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
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7EAF0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Text('$count', style: const TextStyle(color: _textMuted)),
        ],
      ),
    );
  }
}

class _EventsSettingsMenu extends StatelessWidget {
  final EventSortMode sortMode;
  final ValueChanged<EventSortMode?> onSortChanged;
  final bool splitAssigned;
  final ValueChanged<bool> onSplitChanged;

  const _EventsSettingsMenu({
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
      onPressed: () => _showSettingsMenu(context),
    );
  }

  void _showSettingsMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _SettingsMenuDialog(
        sortMode: sortMode,
        onSortChanged: onSortChanged,
        splitAssigned: splitAssigned,
        onSplitChanged: onSplitChanged,
      ),
    );
  }
}

class _SettingsMenuDialog extends StatefulWidget {
  final EventSortMode sortMode;
  final ValueChanged<EventSortMode?> onSortChanged;
  final bool splitAssigned;
  final ValueChanged<bool> onSplitChanged;

  const _SettingsMenuDialog({
    required this.sortMode,
    required this.onSortChanged,
    required this.splitAssigned,
    required this.onSplitChanged,
  });

  @override
  State<_SettingsMenuDialog> createState() => _SettingsMenuDialogState();
}

class _SettingsMenuDialogState extends State<_SettingsMenuDialog> {
  late EventSortMode _currentSort;
  late bool _currentSplit;

  @override
  void initState() {
    super.initState();
    _currentSort = widget.sortMode;
    _currentSplit = widget.splitAssigned;
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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                initialValue: _currentSort,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: EventSortMode.nameAsc,
                    child: Text('Nome A-Z'),
                  ),
                  DropdownMenuItem(
                    value: EventSortMode.nameDesc,
                    child: Text('Nome Z-A'),
                  ),
                  DropdownMenuItem(
                    value: EventSortMode.dateAsc,
                    child: Text('Data crescente'),
                  ),
                  DropdownMenuItem(
                    value: EventSortMode.dateDesc,
                    child: Text('Data decrescente'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _currentSort = value);
                    widget.onSortChanged(value);
                  }
                },
              ),
              const SizedBox(height: 12),
              const Text(
                'Visualizzazione',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE7EAF0)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
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
                              style: TextStyle(fontSize: 10, color: _textMuted),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: _currentSplit,
                        onChanged: (value) {
                          setState(() => _currentSplit = value);
                          widget.onSplitChanged(value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAssignBottomSheet extends StatefulWidget {
  final Event event;
  final List<dynamic> users;
  final void Function(int? userId) onAssign;

  const _QuickAssignBottomSheet({
    required this.event,
    required this.users,
    required this.onAssign,
  });

  @override
  State<_QuickAssignBottomSheet> createState() =>
      _QuickAssignBottomSheetState();
}

class _QuickAssignBottomSheetState extends State<_QuickAssignBottomSheet> {
  late TextEditingController _searchController;
  List<dynamic> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredUsers = widget.users;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = widget.users;
      } else {
        final lower = query.toLowerCase();
        _filteredUsers = widget.users.where((user) {
          final name = '${user.name} ${user.lastName}'.toLowerCase();
          final email = user.email?.toLowerCase() ?? '';
          return name.contains(lower) || email.contains(lower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            border: Border(
              top: BorderSide(color: const Color(0xFFE7EAF0), width: 1),
              left: BorderSide(color: const Color(0xFFE7EAF0), width: 1),
              right: BorderSide(color: const Color(0xFFE7EAF0), width: 1),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x15000000),
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Assegna evento',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.event.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: _textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(context),
                          iconSize: 24,
                          color: Color(0xFF6B7280),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterUsers,
                  decoration: InputDecoration(
                    hintText: 'Cerca per nome o email...',
                    hintStyle: const TextStyle(color: _textMuted, fontSize: 14),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: _textMuted,
                      size: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: _borderColor,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF4F46E5),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFFAFAFA),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _filteredUsers.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.isEmpty
                              ? 'Nessun utente disponibile'
                              : 'Nessun utente trovato',
                          style: const TextStyle(
                            color: _textMuted,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _filteredUsers.length,
                        itemBuilder: (ctx, index) {
                          final user = _filteredUsers[index];
                          final isAssigned = widget.event.userId == user.id;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => widget.onAssign(
                                  isAssigned ? null : user.id,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                highlightColor: const Color(
                                  0xFF4F46E5,
                                ).withValues(alpha: 0.08),
                                splashColor: const Color(
                                  0xFF4F46E5,
                                ).withValues(alpha: 0.1),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isAssigned
                                        ? const Color(
                                            0xFF4F46E5,
                                          ).withValues(alpha: 0.08)
                                        : const Color(0xFFFAFAFA),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isAssigned
                                          ? const Color(
                                              0xFF4F46E5,
                                            ).withValues(alpha: 0.3)
                                          : const Color(0xFFE5E7EB),
                                      width: isAssigned ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color(
                                            0xFF4F46E5,
                                          ).withValues(alpha: 0.12),
                                          border: isAssigned
                                              ? Border.all(
                                                  color: const Color(
                                                    0xFF4F46E5,
                                                  ),
                                                  width: 2,
                                                )
                                              : null,
                                        ),
                                        child: const Icon(
                                          Icons.person_rounded,
                                          color: Color(0xFF4F46E5),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${user.name} ${user.lastName}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              user.email ?? '',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: _textMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isAssigned)
                                        Tooltip(
                                          message: 'Rimuovi assegnazione',
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.close_rounded,
                                              color: Color(0xFFEF4444),
                                            ),
                                            onPressed: () =>
                                                widget.onAssign(null),
                                            iconSize: 20,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                              minWidth: 32,
                                              minHeight: 32,
                                            ),
                                          ),
                                        )
                                      else
                                        const SizedBox(width: 32),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
