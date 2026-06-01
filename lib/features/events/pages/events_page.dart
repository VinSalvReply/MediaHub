import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:mediahub/features/events/controllers/events_controller.dart';
import 'package:mediahub/features/events/widgets/event_form_dialog.dart';
import 'package:mediahub/features/events/widgets/event_list_tile.dart';
import 'package:mediahub/features/users/models/event.dart';

const _bgColor = Color(0xFFF5F7FB);
const _borderColor = Color(0xFFE7EAF0);
const _textMuted = Color(0xFF6B7280);

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late final EventsController controller;
  final GlobalKey<_AssignmentSidebarState> _assignmentSidebarKey =
      GlobalKey<_AssignmentSidebarState>();

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
    await controller.addEvent(
      title: result.title,
      date: result.date,
      attendees: result.attendees,
      status: result.status,
    );
    _toast('Evento creato');
  }

  Future<void> _openEditDialog(Event event) async {
    final result = await showDialog<EventFormResult>(
      context: context,
      builder: (_) => EventFormDialog(initial: event),
    );
    if (result == null) return;
    await controller.editEvent(
      original: event,
      title: result.title,
      date: result.date,
      attendees: result.attendees,
      status: result.status,
    );
    _toast('Evento aggiornato');
  }

  Future<void> _assign(Event event, int? userId) async {
    if (userId == null) return;
    await controller.assignEventToUser(event, userId);
    if (!mounted) return;
    _toast('Evento assegnato all\'utente');
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
    await controller.removeEvent(event);
    _toast('Evento eliminato');
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
        return Container(
          color: _bgColor,
          child: SingleChildScrollView(
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
                  onDragCursorMove: (position) {
                    _assignmentSidebarKey.currentState?.autoScrollAt(position);
                  },
                  assignmentSidebarKey: _assignmentSidebarKey,
                  onEdit: _openEditDialog,
                  onDelete: _confirmDelete,
                  onCreate: _openCreateDialog,
                ),
              ],
            ),
          ),
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
                'Crea e modifica eventi globali',
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
  final ValueChanged<Offset> onDragCursorMove;
  final GlobalKey<_AssignmentSidebarState> assignmentSidebarKey;
  final ValueChanged<Event> onEdit;
  final ValueChanged<Event> onDelete;
  final VoidCallback onCreate;

  const _EventsWorkspace({
    required this.controller,
    required this.onAssign,
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
        if (compact) {
          return Column(
            children: [
              _EventsBody(
                controller: controller,
                onDragCursorMove: onDragCursorMove,
                onEdit: onEdit,
                onDelete: onDelete,
                onCreate: onCreate,
              ),
              const SizedBox(height: 16),
              _AssignmentSidebar(
                key: assignmentSidebarKey,
                controller: controller,
                onAssign: onAssign,
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
                onDragCursorMove: onDragCursorMove,
                onEdit: onEdit,
                onDelete: onDelete,
                onCreate: onCreate,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: _AssignmentSidebar(
                key: assignmentSidebarKey,
                controller: controller,
                onAssign: onAssign,
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

  const _AssignmentSidebar({
    super.key,
    required this.controller,
    required this.onAssign,
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
          child: ListView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            children: [
              const Text(
                'Utenti (drop target)',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Trascina le card evento da sinistra verso un utente.',
                style: TextStyle(fontSize: 12, color: _textMuted),
              ),
              const SizedBox(height: 10),
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
                    onAccept: (event) => widget.onAssign(event, user.id),
                  ),
                );
              }),
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
  final ValueChanged<Event> onAccept;

  const _EventDropZone({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.events,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<Event>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) => onAccept(details.data),
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
  final ValueChanged<Offset> onDragCursorMove;
  final ValueChanged<Event> onEdit;
  final ValueChanged<Event> onDelete;
  final VoidCallback onCreate;

  const _EventsBody({
    required this.controller,
    required this.onDragCursorMove,
    required this.onEdit,
    required this.onDelete,
    required this.onCreate,
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

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Eventi globali',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              for (final event in controller.events)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Draggable<Event>(
                    data: event,
                    onDragUpdate: (details) =>
                        onDragCursorMove(details.globalPosition),
                    feedback: Material(
                      color: Colors.transparent,
                      child: SizedBox(
                        width: 480,
                        child: EventListTile(
                          event: event,
                          onEdit: () {},
                          onDelete: () {},
                        ),
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.45,
                      child: EventListTile(
                        event: event,
                        onEdit: () => onEdit(event),
                        onDelete: () => onDelete(event),
                      ),
                    ),
                    child: EventListTile(
                      event: event,
                      onEdit: () => onEdit(event),
                      onDelete: () => onDelete(event),
                    ),
                  ),
                ),
            ],
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
}
