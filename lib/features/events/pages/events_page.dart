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
  final GlobalKey<_AssignmentSidebarState> _assignmentSidebarKey =
      GlobalKey<_AssignmentSidebarState>();
  bool _isDraggingEvent = false;
  bool _dragFromUserDropZone = false;
  bool _isHoveringUserDropZone = false;
  EventSortMode _sortMode = EventSortMode.dateAsc;
  bool _splitAssigned = false;
  bool _previousSplitAssigned = false;
  int _sortTick = 0;
  Map<int, int> _previousAllEventIndexes = const {};
  Map<int, int> _previousAssignedEventIndexes = const {};
  Map<int, int> _previousUnassignedEventIndexes = const {};

  void _startEventDragFromGlobalList() {
    if (_isDraggingEvent && !_dragFromUserDropZone) return;
    setState(() {
      _isDraggingEvent = true;
      _dragFromUserDropZone = false;
      _isHoveringUserDropZone = false;
    });
  }

  void _startEventDragFromUserDropZone() {
    if (_isDraggingEvent && _dragFromUserDropZone) return;
    setState(() {
      _isDraggingEvent = true;
      _dragFromUserDropZone = true;
      _isHoveringUserDropZone = false;
    });
  }

  void _setUserDropZoneHover(bool value) {
    if (_isHoveringUserDropZone == value) return;
    setState(() {
      _isHoveringUserDropZone = value;
    });
  }

  void _endEventDrag() {
    if (!_isDraggingEvent && !_dragFromUserDropZone) {
      return;
    }
    setState(() {
      _isDraggingEvent = false;
      _dragFromUserDropZone = false;
      _isHoveringUserDropZone = false;
    });
  }

  void _handleSidebarItemDragEnd(Event event, DraggableDetails details) {
    if (!details.wasAccepted) {
      _unassign(event);
    }
    _endEventDrag();
  }

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
            final isMobile = constraints.maxWidth < 1120;

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
                          isDragging: _isDraggingEvent,
                          onGlobalListDragStart: _startEventDragFromGlobalList,
                          onSidebarDragStart: _startEventDragFromUserDropZone,
                          onDragEnd: _endEventDrag,
                          onSidebarItemDragEnd: _handleSidebarItemDragEnd,
                          onUserDropZoneHoverChanged: _setUserDropZoneHover,
                          onDragCursorMove: (position) {
                            _assignmentSidebarKey.currentState?.autoScrollAt(
                              position,
                            );
                          },
                          assignmentSidebarKey: _assignmentSidebarKey,
                          onEdit: _openEditDialog,
                          onDelete: _confirmDelete,
                          onCreate: _openCreateDialog,
                        ),
                      ],
                    ),
                  ),
                  if (isMobile && _isDraggingEvent && !_dragFromUserDropZone)
                    _MobileUserOverlay(
                      controller: controller,
                      isDragging: _isDraggingEvent,
                      onAssign: _assign,
                      onDragEnd: _endEventDrag,
                    ),
                  if (_isDraggingEvent && _dragFromUserDropZone)
                    AnimatedCrossFade(
                      firstChild: const _GlobalAssignOverlay(),
                      secondChild: const _GlobalUnassignOverlay(),
                      crossFadeState: _isHoveringUserDropZone
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: const Duration(milliseconds: 200),
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
  final bool isDragging;
  final VoidCallback onGlobalListDragStart;
  final VoidCallback onSidebarDragStart;
  final VoidCallback onDragEnd;
  final void Function(Event event, DraggableDetails details)
  onSidebarItemDragEnd;
  final ValueChanged<bool> onUserDropZoneHoverChanged;
  final ValueChanged<Offset> onDragCursorMove;
  final GlobalKey<_AssignmentSidebarState> assignmentSidebarKey;
  final ValueChanged<Event> onEdit;
  final ValueChanged<Event> onDelete;
  final VoidCallback onCreate;

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
    required this.isDragging,
    required this.onGlobalListDragStart,
    required this.onSidebarDragStart,
    required this.onDragEnd,
    required this.onSidebarItemDragEnd,
    required this.onUserDropZoneHoverChanged,
    required this.onDragCursorMove,
    required this.assignmentSidebarKey,
    required this.onEdit,
    required this.onDelete,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 1120;
        final enableDragDrop = constraints.maxWidth >= 700;
        if (compact) {
          if (!enableDragDrop) {
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
              onGlobalListDragStart: onGlobalListDragStart,
              onDragEnd: onDragEnd,
              onDragCursorMove: onDragCursorMove,
              onEdit: onEdit,
              onDelete: onDelete,
              onCreate: onCreate,
              enableDragDrop: false,
              onAssign: onAssign,
              onUnassign: onUnassign,
            );
          }
          return Column(
            children: [
              _EventsBody(
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
                onGlobalListDragStart: onGlobalListDragStart,
                onDragEnd: onDragEnd,
                onDragCursorMove: onDragCursorMove,
                onEdit: onEdit,
                onDelete: onDelete,
                onCreate: onCreate,
                enableDragDrop: true,
                onAssign: onAssign,
                onUnassign: onUnassign,
              ),
              const SizedBox(height: 16),
              _AssignmentSidebar(
                key: assignmentSidebarKey,
                controller: controller,
                onAssign: onAssign,
                onSidebarDragStart: onSidebarDragStart,
                onDragEnd: onDragEnd,
                onSidebarItemDragEnd: onSidebarItemDragEnd,
                onUserDropZoneHoverChanged: onUserDropZoneHoverChanged,
                onDragCursorMove: onDragCursorMove,
                dragActive: isDragging,
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: _EventsBody(
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
                onGlobalListDragStart: onGlobalListDragStart,
                onDragEnd: onDragEnd,
                onDragCursorMove: onDragCursorMove,
                onEdit: onEdit,
                onDelete: onDelete,
                onCreate: onCreate,
                enableDragDrop: true,
                onAssign: onAssign,
                onUnassign: onUnassign,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: _AssignmentSidebar(
                key: assignmentSidebarKey,
                controller: controller,
                onAssign: onAssign,
                onSidebarDragStart: onSidebarDragStart,
                onDragEnd: onDragEnd,
                onSidebarItemDragEnd: onSidebarItemDragEnd,
                onUserDropZoneHoverChanged: onUserDropZoneHoverChanged,
                onDragCursorMove: onDragCursorMove,
                dragActive: isDragging,
              ),
            ),
          ],
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
    super.key,
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
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<Event>(
      onWillAcceptWithDetails: (_) {
        onUserDropZoneHoverChanged(true);
        return true;
      },
      onMove: (_) => onUserDropZoneHoverChanged(true),
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

class _GlobalAssignOverlay extends StatelessWidget {
  const _GlobalAssignOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
            border: Border.all(color: const Color(0xFF4F46E5), width: 2.5),
          ),
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF3730A3).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Text(
                'Rilascia su un utente per assegnare l\'evento',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlobalUnassignOverlay extends StatelessWidget {
  const _GlobalUnassignOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444).withValues(alpha: 0.16),
            border: Border.all(color: const Color(0xFFEF4444), width: 2.5),
          ),
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF7F1D1D).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Text(
                'Rilascia fuori dagli utenti per disassegnare l\'evento',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
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
  final VoidCallback onGlobalListDragStart;
  final VoidCallback onDragEnd;
  final ValueChanged<Offset> onDragCursorMove;
  final ValueChanged<Event> onEdit;
  final ValueChanged<Event> onDelete;
  final VoidCallback onCreate;
  final bool enableDragDrop;
  final Future<void> Function(Event event, int? userId) onAssign;
  final Future<void> Function(Event event) onUnassign;

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
    required this.onGlobalListDragStart,
    required this.onDragEnd,
    required this.onDragCursorMove,
    required this.onEdit,
    required this.onDelete,
    required this.onCreate,
    required this.enableDragDrop,
    required this.onAssign,
    required this.onUnassign,
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
              SizedBox(
                width: 210,
                child: DropdownButtonFormField<EventSortMode>(
                  initialValue: sortMode,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
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
                  onChanged: onSortChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Dividi vista: assegnati a sinistra, non assegnati a destra',
                  style: TextStyle(fontSize: 12, color: _textMuted),
                ),
              ),
              Switch.adaptive(value: splitAssigned, onChanged: onSplitChanged),
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
                child: child,
              );
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 700;
                return isMobile
                    ? _SwipeableEventCard(
                        event: source[i],
                        onEdit: () => onEdit(source[i]),
                        onDelete: () => onDelete(source[i]),
                        onAssign: onAssign,
                        onUnassign: onUnassign,
                        controller: controller,
                      )
                    : Draggable<Event>(
                        data: source[i],
                        onDragStarted: onGlobalListDragStart,
                        onDragUpdate: (details) =>
                            onDragCursorMove(details.globalPosition),
                        onDragEnd: (_) => onDragEnd(),
                        onDragCompleted: onDragEnd,
                        onDraggableCanceled: (_, _) => onDragEnd(),
                        feedback: Material(
                          color: Colors.transparent,
                          child: SizedBox(
                            width: 480,
                            child: EventListTile(
                              event: source[i],
                              onEdit: () {},
                              onDelete: () {},
                            ),
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.45,
                          child: EventListTile(
                            event: source[i],
                            onEdit: () => onEdit(source[i]),
                            onDelete: () => onDelete(source[i]),
                          ),
                        ),
                        child: EventListTile(
                          event: source[i],
                          onEdit: () => onEdit(source[i]),
                          onDelete: () => onDelete(source[i]),
                        ),
                      );
              },
            ),
          ),
        ),
    ];
  }
}

class _SwipeableEventCard extends StatefulWidget {
  final Event event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Future<void> Function(Event event, int? userId) onAssign;
  final Future<void> Function(Event event) onUnassign;
  final EventsController controller;

  const _SwipeableEventCard({
    required this.event,
    required this.onEdit,
    required this.onDelete,
    required this.onAssign,
    required this.onUnassign,
    required this.controller,
  });

  @override
  State<_SwipeableEventCard> createState() => _SwipeableEventCardState();
}

class _SwipeableEventCardState extends State<_SwipeableEventCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _springController;
  late Animation<double> _springAnimation;
  double _dragOffset = 0;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _springAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _springController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _springController.dispose();
    super.dispose();
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_isAnimating) return;

    final velocity = details.velocity.pixelsPerSecond.dx;
    final threshold = 60.0;

    if (_dragOffset.abs() < threshold && velocity.abs() < 300) {
      _animateBack();
      return;
    }

    if (_dragOffset > threshold || velocity > 300) {
      _handleSwipeRight();
    } else if (_dragOffset < -threshold || velocity < -300) {
      _handleSwipeLeft();
    } else {
      _animateBack();
    }
  }

  Future<void> _handleSwipeRight() async {
    _isAnimating = true;
    final userId = await _showAssignBottomSheet();

    if (userId != null && mounted) {
      await widget.onAssign(widget.event, userId);
      if (mounted) {
        _animateBack();
      }
    } else {
      if (mounted) {
        _animateBack();
      }
    }
    _isAnimating = false;
  }

  Future<void> _handleSwipeLeft() async {
    _isAnimating = true;
    await widget.onUnassign(widget.event);
    if (mounted) {
      _animateBack();
    }
    _isAnimating = false;
  }

  void _animateBack() {
    _isAnimating = true;

    _springAnimation = Tween<double>(begin: _dragOffset, end: 0).animate(
      CurvedAnimation(parent: _springController, curve: Curves.elasticOut),
    );

    _springController.forward(from: 0).whenComplete(() {
      if (mounted) {
        setState(() {
          _dragOffset = 0;
          _isAnimating = false;
        });
      }
    });
  }

  Future<int?> _showAssignBottomSheet() {
    return showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text(
                  'Assegna evento',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  widget.event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.controller.users.length,
                  itemBuilder: (context, index) {
                    final user = widget.controller.users[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person_rounded),
                      ),
                      title: Text('${user.name} ${user.lastName}'),
                      subtitle: Text(user.email),
                      onTap: () => Navigator.of(context).pop(user.id),
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (_isAnimating) return;

        setState(() {
          _dragOffset += details.delta.dx;
          _dragOffset = _dragOffset.clamp(-120.0, 120.0);

        });
      },
      onHorizontalDragEnd: _handleDragEnd,
      child: AnimatedBuilder(
        animation: _springController,
        builder: (context, child) {
          final offset = _isAnimating ? _springAnimation.value : _dragOffset;
          final normalizedOffset = (offset.abs() / 120).clamp(0.0, 1.0);

          return Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: offset > 0
                        ? const Color(0xFFEEF2FF)
                        : offset < 0
                        ? const Color(0xFFFEE2E2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Builder(
                    builder: (context) {
                      if (offset > 10) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Opacity(
                              opacity: normalizedOffset,
                              child: const Icon(
                                Icons.person_add_alt_rounded,
                                color: Color(0xFF4F46E5),
                                size: 48,
                              ),
                            ),
                          ),
                        );
                      }

                      if (offset < -10) {
                        return Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Opacity(
                              opacity: normalizedOffset,
                              child: const Icon(
                                Icons.link_off_rounded,
                                color: Color(0xFFEF4444),
                                size: 48,
                              ),
                            ),
                          ),
                        );
                      }

                      return const SizedBox();
                    },
                  ),
                ),
              ),

              Transform.translate(
                offset: Offset(offset, 0),
                child: EventListTile(
                  event: widget.event,
                  onEdit: widget.onEdit,
                  onDelete: widget.onDelete,
                ),
              ),
            ],
          );
        },
      ),
    );
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

class _MobileUserOverlay extends StatefulWidget {
  final EventsController controller;
  final bool isDragging;
  final Future<void> Function(Event event, int? userId) onAssign;
  final VoidCallback onDragEnd;

  const _MobileUserOverlay({
    required this.controller,
    required this.isDragging,
    required this.onAssign,
    required this.onDragEnd,
  });

  @override
  State<_MobileUserOverlay> createState() => _MobileUserOverlayState();
}

class _MobileUserOverlayState extends State<_MobileUserOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _slideUp;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideUp = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, 100 * _slideUp.value),
          child: Opacity(
            opacity: _fade.value,
            child: Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onDragEnd,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      constraints: const BoxConstraints(maxHeight: 400),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: _borderColor),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 30,
                            offset: Offset(0, 12),
                            color: Color(0x1A000000),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Assegna a utente',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Rilascia su un utente per assegnare l\'evento',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              children: [
                                ...widget.controller.users.map((user) {
                                  final userEvents = widget.controller.events
                                      .where((event) => event.userId == user.id)
                                      .length;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: DragTarget<Event>(
                                      onWillAcceptWithDetails: (_) => true,
                                      onAcceptWithDetails: (details) {
                                        widget.onAssign(details.data, user.id);
                                        Future.delayed(
                                          const Duration(milliseconds: 200),
                                          widget.onDragEnd,
                                        );
                                      },
                                      builder: (context, candidateData, _) {
                                        final isActive =
                                            candidateData.isNotEmpty;
                                        return AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 140,
                                          ),
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: isActive
                                                ? const Color(0xFFEEF2FF)
                                                : const Color(0xFFF8FAFC),
                                            border: Border.all(
                                              color: isActive
                                                  ? const Color(0xFF4F46E5)
                                                  : _borderColor,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: const Color(
                                                    0xFF4F46E5,
                                                  ).withValues(alpha: 0.12),
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
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    Text(
                                                      user.email,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: _textMuted,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFF3F4F6,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  '$userEvents',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: _textMuted,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: SizedBox(
                              width: double.infinity,
                              child: FilledButton.tonal(
                                onPressed: widget.onDragEnd,
                                child: const Text('Chiudi'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
